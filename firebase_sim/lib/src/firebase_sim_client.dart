import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';
import 'package:tekartik_firebase/src/firestore_common.dart';
import 'package:tekartik_firebase/storage.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/rpc_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_common.dart';
import 'package:tekartik_web_socket/web_socket.dart';

class DocumentDataSim extends DocumentDataMap {}

class SimDocumentSnapshot implements DocumentSnapshot {
  @override
  final DocumentReferenceSim ref;

  final bool exists;

  final DocumentData documentData;

  SimDocumentSnapshot(this.ref, this.exists, this.documentData);

  @override
  Map<String, dynamic> get data => documentData?.asMap();
}

class DocumentReferenceSim implements DocumentReference {
  final FirestoreSim simFirestore;

  @override
  final String path;

  DocumentReferenceSim(this.simFirestore, this.path);

  @override
  CollectionReference collection(String path) =>
      new CollectionReferenceSim(simFirestore, url.join(this.path, path));

  @override
  Future delete() async {
    var simClient = await simFirestore.app.simClient;
    var firestoreDeleteData = new FirestorePathData()..path = path;
    var request = simClient.newRequest(
        methodFirestoreDelete, firestoreDeleteData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
  }

  @override
  Future<DocumentSnapshot> get() async {
    var simClient = await simFirestore.app.simClient;
    var firestorePathData = new FirestorePathData()..path = path;
    var request =
        simClient.newRequest(methodFirestoreGet, firestorePathData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }

    var documentSnapshotData = new FirestoreDocumentSnapshotDataImpl()
      ..fromMap((response as Response).result as Map<String, dynamic>);
    return new SimDocumentSnapshot(
        new DocumentReferenceSim(simFirestore, documentSnapshotData.path),
        documentSnapshotData.data != null,
        documentDataFromJsonMap(simFirestore, documentSnapshotData.data));
  }

  @override
  String get id => url.basename(path);

  @override
  CollectionReference get parent =>
      new CollectionReferenceSim(simFirestore, url.dirname(path));

  @override
  Future set(Map<String, dynamic> data, [SetOptions options]) async {
    var jsonMap = documentDataToJsonMap(new DocumentData(data));
    var simClient = await simFirestore.app.simClient;
    var firestoreSetData = new FirestoreSetData()
      ..path = path
      ..data = jsonMap
      ..merge = options?.merge;
    var request =
        simClient.newRequest(methodFirestoreSet, firestoreSetData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
  }

  @override
  Future update(Map<String, dynamic> data) async {
    var jsonMap = documentDataToJsonMap(new DocumentData(data));
    var simClient = await simFirestore.app.simClient;
    var firestoreSetData = new FirestoreSetData()
      ..path = path
      ..data = jsonMap;
    var request =
        simClient.newRequest(methodFirestoreUpdate, firestoreSetData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
  }

  SimDocumentSnapshot documentSnapshotFromDataMap(
          String path, Map<String, dynamic> map) =>
      simFirestore.documentSnapshotFromDataMap(path, map);

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    ServerSubscriptionSim<SimDocumentSnapshot> subscription;
    subscription = new ServerSubscriptionSim(new StreamController(
        onCancel: () => simFirestore.removeSubscription(subscription)));

    () async {
      var simClient = await simFirestore.app.simClient;

      // register for notification until done
      subscription.notificationSubscription =
          simClient.notificationStream.listen((Notification notification) {
        if (notification.method == methodFirestoreGetStream) {
          // for us?
          if (notificationParams(notification)['streamId'] ==
              subscription.streamId) {
            var snaphostData = new FirestoreDocumentSnapshotDataImpl()
              ..fromMap(notificationParams(notification));

            var snapshot = simFirestore.documentSnapshotFromData(snaphostData);
            subscription.add(snapshot);
          }
        }
      });
      // request
      // getStream(path)
      var data = new FirestoreGetData()..path = path;
      var request =
          simClient.newRequest(methodFirestoreGetStream, data.toMap());
      var response = await simClient.sendRequest(request);
      if (response is ErrorResponse) {
        throw response.error;
      }

      var responseData = new FirestoreQueryStreamResponse()
        ..fromMap((response as Response).result as Map<String, dynamic>);
      subscription.streamId = responseData.streamId;
      simFirestore.addSubscription(subscription);
    }();
    return subscription.stream;
  }
}

abstract class QueryMixinSim implements Query {
  QueryInfo get queryInfo;

  CollectionReferenceSim get simCollectionReference;

  QuerySim clone() {
    return new QuerySim(simCollectionReference)..queryInfo = queryInfo?.clone();
  }

  @override
  Query where(
    String fieldPath, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  }) =>
      clone()
        ..queryInfo.addWhere(new WhereInfo(fieldPath,
            isEqualTo: isEqualTo,
            isLessThan: isLessThan,
            isLessThanOrEqualTo: isGreaterThanOrEqualTo,
            isGreaterThan: isGreaterThan,
            isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            isNull: isNull));

  addOrderBy(String key, String directionStr) {
    var orderBy = new OrderByInfo()
      ..fieldPath = key
      ..ascending = directionStr != orderByDescending;
    queryInfo.orderBys.add(orderBy);
  }

  @override
  Query startAt({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.startAt(snapshot: snapshot, values: values);

  @override
  Query startAfter({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.startAfter(snapshot: snapshot, values: values);

  @override
  Query endAt({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.endAt(snapshot: snapshot, values: values);

  @override
  Query endBefore({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.endBefore(snapshot: snapshot, values: values);

  @override
  Query select(List<String> list) {
    return clone()..queryInfo.selectKeyPaths = list;
  }

  @override
  Query limit(int limit) => clone()..queryInfo.limit = limit;

  @override
  Query orderBy(String key, {bool descending}) => clone()
    ..addOrderBy(
        key, descending == true ? orderByDescending : orderByAscending);

  SimDocumentSnapshot documentSnapshotFromData(
      DocumentSnapshotData documentSnapshotData) {
    return documentSnapshotFromDataMap(
        documentSnapshotData.path, documentSnapshotData.data);
  }

  SimDocumentSnapshot documentSnapshotFromDataMap(
          String path, Map<String, dynamic> map) =>
      simCollectionReference.simFirestore
          .documentSnapshotFromDataMap(path, map);

  @override
  Future<QuerySnapshot> get() async {
    var simClient = await simCollectionReference.simFirestore.app.simClient;
    var data = new FirestoreQueryData()
      ..path = simCollectionReference.path
      ..queryInfo = queryInfo;
    var request = simClient.newRequest(methodFirestoreQuery, data.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }

    var querySnapshotData = new FirestoreQuerySnapshotData()
      ..fromMap((response as Response).result as Map<String, dynamic>);
    return new QuerySnapshotSim(
        querySnapshotData.list
            .map((DocumentSnapshotData documentSnapshotData) =>
                documentSnapshotFromData(documentSnapshotData))
            .toList(),
        <DocumentChangeSim>[]);
  }

  @override
  Stream<QuerySnapshot> onSnapshot() {
    var simFirestore = simCollectionReference.simFirestore;

    ServerSubscriptionSim<QuerySnapshot> subscription;
    subscription = new ServerSubscriptionSim(new StreamController(
        onCancel: () => simFirestore.removeSubscription(subscription)));

    () async {
      var simClient = await simFirestore.app.simClient;

      // register for notification until done
      subscription.notificationSubscription =
          simClient.notificationStream.listen((Notification notification) {
        if (notification.method == methodFirestoreQueryStream) {
          // for us?
          if (notificationParams(notification)['streamId'] ==
              subscription.streamId) {
            var querySnapshotData = new FirestoreQuerySnapshotData()
              ..fromMap(notificationParams(notification));

            var docs = querySnapshotData.list
                .map((DocumentSnapshotData documentSnapshotData) =>
                    documentSnapshotFromData(documentSnapshotData))
                .toList();

            var changes = <DocumentChangeSim>[];
            for (var changeData in querySnapshotData.changes) {
              // snapshot present?
              SimDocumentSnapshot snapshot;
              if (changeData.data != null) {
                snapshot = documentSnapshotFromDataMap(
                    join(simCollectionReference.path, changeData.id),
                    changeData.data);
              } else {
                // find in doc
                snapshot = snapshotsFindById(docs, changeData.id);
              }
              DocumentChangeSim change = new DocumentChangeSim(
                  documentChangeTypeFromString(changeData.type),
                  snapshot,
                  changeData.newIndex,
                  changeData.oldIndex);
              changes.add(change);
            }
            var snapshot = new QuerySnapshotSim(docs, changes);
            subscription.add(snapshot);
          }
        }
      });
      var data = new FirestoreQueryData()
        ..path = simCollectionReference.path
        ..queryInfo = queryInfo;
      var request =
          simClient.newRequest(methodFirestoreQueryStream, data.toMap());
      var response = await simClient.sendRequest(request);
      if (response is ErrorResponse) {
        throw response.error;
      }

      var responseData = new FirestoreQueryStreamResponse()
        ..fromMap((response as Response).result as Map<String, dynamic>);
      subscription.streamId = responseData.streamId;
      simFirestore.addSubscription(subscription);
    }();
    return subscription.stream;
  }
}

class ServerSubscriptionSim<T> {
  // the streamId;
  int streamId;
  final StreamController<T> _controller;

  // register for notification during the query
  StreamSubscription<Notification> notificationSubscription;

  ServerSubscriptionSim(this._controller);

  Stream<T> get stream => _controller.stream;

  Future close() async {
    notificationSubscription?.cancel();
    await _controller.close();
  }

  void add(T snapshot) {
    _controller.add(snapshot);
  }
}

class DocumentChangeSim implements DocumentChange {
  @override
  final DocumentChangeType type;

  @override
  final SimDocumentSnapshot document;

  @override
  final int newIndex;

  @override
  final int oldIndex;

  DocumentChangeSim(this.type, this.document, this.newIndex, this.oldIndex);
}

class QuerySnapshotSim implements QuerySnapshot {
  final List<SimDocumentSnapshot> simDocs;
  final List<DocumentChangeSim> simDocChanges;

  QuerySnapshotSim(this.simDocs, this.simDocChanges);

  @override
  List<DocumentSnapshot> get docs => simDocs;

  // TODO: implement documentChanges
  @override
  List<DocumentChange> get documentChanges => simDocChanges;
}

class QuerySim extends Object with QueryMixinSim implements Query {
  final CollectionReferenceSim simCollectionReference;

  FirestoreSim get simFirestore => simCollectionReference.simFirestore;
  QueryInfo queryInfo;

  QuerySim(this.simCollectionReference);
}

class CollectionReferenceSim extends Object
    with QueryMixinSim
    implements CollectionReference {
  @override
  QueryInfo queryInfo = new QueryInfo();

  CollectionReferenceSim get simCollectionReference => this;
  final FirestoreSim simFirestore;

  @override
  final String path;

  CollectionReferenceSim(this.simFirestore, this.path);

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    var jsonMap = documentDataToJsonMap(new DocumentData(data));
    var simClient = await simFirestore.app.simClient;
    var firestoreSetData = new FirestoreSetData()
      ..path = path
      ..data = jsonMap;
    var request =
        simClient.newRequest(methodFirestoreAdd, firestoreSetData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
    var firestorePathData = new FirestorePathData()
      ..fromMap((response as Response).result as Map<String, dynamic>);
    return new DocumentReferenceSim(simFirestore, firestorePathData.path);
  }

  @override
  DocumentReference doc([String path]) =>
      new DocumentReferenceSim(simFirestore, url.join(this.path, path));

  @override
  String get id => url.basename(path);

  @override
  DocumentReference get parent =>
      new DocumentReferenceSim(simFirestore, url.dirname(path));
}

class FirestoreServiceSim implements FirestoreService {
  FirestoreServiceSim();

  @override
  bool get supportsQuerySelect => true;
}

class FirestoreSim implements Firestore {
  // The key is the streamId from the server
  final Map<int, ServerSubscriptionSim> _subscriptions = {};

  addSubscription(ServerSubscriptionSim subscription) {
    _subscriptions[subscription.streamId] = subscription;
  }

  final AppSim app;

  FirestoreSim(this.app);

  @override
  CollectionReference collection(String path) =>
      new CollectionReferenceSim(this, path);

  @override
  DocumentReference doc(String path) => new DocumentReferenceSim(this, path);

  Future removeSubscription(ServerSubscriptionSim subscription) async {
    _subscriptions.remove(subscription.streamId);
    await subscription.close();
  }

  Future close() async {
    var subscriptions = _subscriptions.values.toList();
    for (var subscription in subscriptions) {
      await removeSubscription(subscription);
    }
  }

  SimDocumentSnapshot documentSnapshotFromData(
      FirestoreDocumentSnapshotData documentSnapshotData) {
    return documentSnapshotFromDataMap(
        documentSnapshotData.path, documentSnapshotData.data);
  }

  SimDocumentSnapshot documentSnapshotFromDataMap(
      String path, Map<String, dynamic> map) {
    return new SimDocumentSnapshot(new DocumentReferenceSim(this, path),
        map != null, documentDataFromJsonMap(this, map));
  }

  @override
  WriteBatch batch() => new WriteBatchSim(this);

  @override
  Future runTransaction(
      Function(Transaction transaction) updateFunction) async {
    // TransactionSim transactionSim = new TransactionSim(this);
    throw 'not implemented yet';
  }
}

/*
class TransactionSim implements Transaction {
  final SimFirestore firestore;

  TransactionSim(this.firestore);

  @override
  void delete(DocumentReference documentRef) {
    // TODO: implement delete
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) {
    // TODO: implement get
  }

  @override
  void set(DocumentReference documentRef, DocumentData data, [SetOptions options]) {
    // TODO: implement set
  }

  @override
  void update(DocumentReference documentRef, DocumentData data) {
    // TODO: implement update
  }
}
*/
class WriteBatchSim extends WriteBatchBase {
  final FirestoreSim firestore;

  WriteBatchSim(this.firestore);

  @override
  Future commit() async {
    var batchData = new FirestoreBatchData();
    for (var operation in operations) {
      if (operation is WriteBatchOperationDelete) {
        batchData.operations.add(new BatchOperationDeleteData()
          ..method = methodFirestoreDelete
          ..path = operation.docRef.path);
      } else if (operation is WriteBatchOperationSet) {
        batchData.operations.add(new BatchOperationSetData()
          ..method = methodFirestoreSet
          ..path = operation.docRef.path
          ..data = documentDataToJsonMap(operation.documentData)
          ..merge = operation.options?.merge);
      } else if (operation is WriteBatchOperationUpdate) {
        batchData.operations.add(new BatchOperationUpdateData()
          ..method = methodFirestoreUpdate
          ..path = operation.docRef.path
          ..data = documentDataToJsonMap(operation.documentData));
      } else {
        throw 'not supported $operation';
      }
    }
    var simClient = await firestore.app.simClient;
    var request = simClient.newRequest(methodFirestoreBatch, batchData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
  }
}

class AppSim implements App {
  final FirebaseSim admin;
  bool deleted = false;
  String _name;

  // when ready
  WebSocketChannel<String> webSocketChannel;
  Completer<FirebaseSimClient> readyCompleter;

  Future<FirebaseSimClient> get simClient async {
    if (readyCompleter == null) {
      readyCompleter = new Completer();
      webSocketChannel = await admin.clientFactory.connect(admin.url);
      var simClient = new FirebaseSimClient(webSocketChannel);
      var adminInitializeAppData = new AdminInitializeAppData()
        ..projectId = options?.projectId
        ..name = name;
      var request = simClient.newRequest(
          methodAdminInitializeApp, adminInitializeAppData.toMap());
      var response = await simClient.sendRequest(request);
      if (response is ErrorResponse) {
        readyCompleter.completeError(response.error);
      }
      readyCompleter.complete(simClient);
    }
    return readyCompleter.future;
  }

  AppSim(this.admin, this.options, this._name) {
    _name ??= firebaseAppNameDefault;
  }

  @override
  Future delete() async {
    if (!deleted) {
      deleted = true;
      await _firestore?.close();
    }
  }

  @override
  String get name => _name;

  FirestoreSim _firestore;

  @override
  Firestore firestore() => _firestore ??= new FirestoreSim(this);

  @override
  final AppOptions options;

  @override
  Storage storage() {
    // TODO: implement storage
    throw 'not implemented yet';
  }

  // basic ping feature with console display
  Future ping() async {
    var simClient = await this.simClient;
    var request = simClient.newRequest(methodPing);
    print("sending: ${request}");
    var response = await simClient.sendRequest(request);
    print("receiving: ${response}");
  }
}

class FirebaseSim implements Firebase {
  final WebSocketChannelClientFactory clientFactory;
  final String url;

  FirebaseSim({this.clientFactory, this.url});

  @override
  App initializeApp({AppOptions options, String name}) {
    return new AppSim(this, options, name);
  }

  @override
  FirestoreService firestore = new FirestoreServiceSim();
}
