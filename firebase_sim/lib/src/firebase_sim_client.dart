import 'dart:async';

import 'package:meta/meta.dart';
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

class DocumentSnapshotSim implements DocumentSnapshot {
  @override
  final DocumentReferenceSim ref;

  final bool exists;

  final DocumentData documentData;

  DocumentSnapshotSim(this.ref, this.exists, this.documentData,
      {@required this.createTime, @required this.updateTime});

  @override
  Map<String, dynamic> get data => documentData?.asMap();

  @override
  final Timestamp updateTime;

  @override
  final Timestamp createTime;
}

class DocumentReferenceSim implements DocumentReference {
  final FirestoreSim simFirestore;

  @override
  final String path;

  DocumentReferenceSim(this.simFirestore, this.path);

  @override
  CollectionReference collection(String path) =>
      CollectionReferenceSim(simFirestore, url.join(this.path, path));

  @override
  Future delete() async {
    var simClient = await simFirestore.app.simClient;
    var firestoreDeleteData = FirestorePathData()..path = path;
    var request = simClient.newRequest(
        methodFirestoreDelete, firestoreDeleteData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
  }

  @override
  Future<DocumentSnapshot> get() {
    var requestData = FirestoreGetRequestData()..path = path;
    return simFirestore.get(requestData);
  }

  @override
  String get id => url.basename(path);

  @override
  CollectionReference get parent =>
      CollectionReferenceSim(simFirestore, url.dirname(path));

  @override
  Future set(Map<String, dynamic> data, [SetOptions options]) async {
    var jsonMap = documentDataToJsonMap(DocumentData(data));
    var simClient = await simFirestore.app.simClient;
    var firestoreSetData = FirestoreSetData()
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
    var jsonMap = documentDataToJsonMap(DocumentData(data));
    var simClient = await simFirestore.app.simClient;
    var firestoreSetData = FirestoreSetData()
      ..path = path
      ..data = jsonMap;
    var request =
        simClient.newRequest(methodFirestoreUpdate, firestoreSetData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
  }

  DocumentSnapshotSim documentSnapshotFromDataMap(
          String path, Map<String, dynamic> map) =>
      simFirestore.documentSnapshotFromDataMap(path, map);

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    ServerSubscriptionSim<DocumentSnapshotSim> subscription;
    subscription = ServerSubscriptionSim(StreamController(
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
            var snaphostData = FirestoreDocumentSnapshotDataImpl()
              ..fromMap(notificationParams(notification));

            var snapshot = simFirestore.documentSnapshotFromData(snaphostData);
            subscription.add(snapshot);
          }
        }
      });
      // request
      // getStream(path)
      var data = FirestoreGetData()..path = path;
      var request =
          simClient.newRequest(methodFirestoreGetStream, data.toMap());
      var response = await simClient.sendRequest(request);
      if (response is ErrorResponse) {
        throw response.error;
      }

      var responseData = FirestoreQueryStreamResponse()
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

  FirestoreSim get simFirestore => simCollectionReference.simFirestore;

  QuerySim clone() {
    return QuerySim(simCollectionReference)..queryInfo = queryInfo?.clone();
  }

  @override
  Query where(
    String fieldPath, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    bool isNull,
  }) =>
      clone()
        ..queryInfo.addWhere(WhereInfo(fieldPath,
            isEqualTo: isEqualTo,
            isLessThan: isLessThan,
            isLessThanOrEqualTo: isGreaterThanOrEqualTo,
            isGreaterThan: isGreaterThan,
            isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            arrayContains: arrayContains,
            isNull: isNull));

  addOrderBy(String key, String directionStr) {
    var orderBy = OrderByInfo()
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

  DocumentSnapshotSim documentSnapshotFromData(
      DocumentSnapshotData documentSnapshotData) {
    return simFirestore.documentSnapshotFromData(documentSnapshotData);
  }

  @override
  Future<QuerySnapshot> get() async {
    var simClient = await simCollectionReference.simFirestore.app.simClient;
    var data = FirestoreQueryData()
      ..path = simCollectionReference.path
      ..queryInfo = queryInfo;
    var request = simClient.newRequest(methodFirestoreQuery, data.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }

    var querySnapshotData = FirestoreQuerySnapshotData()
      ..fromMap((response as Response).result as Map<String, dynamic>);
    return QuerySnapshotSim(
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
    subscription = ServerSubscriptionSim(StreamController(
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
            var querySnapshotData = FirestoreQuerySnapshotData()
              ..fromMap(notificationParams(notification));

            var docs = querySnapshotData.list
                .map((DocumentSnapshotData documentSnapshotData) =>
                    documentSnapshotFromData(documentSnapshotData))
                .toList();

            var changes = <DocumentChangeSim>[];
            for (var changeData in querySnapshotData.changes) {
              // snapshot present?
              DocumentSnapshotSim snapshot;
              if (changeData.data != null) {
                snapshot = simFirestore.documentSnapshotFromDataMap(
                    join(simCollectionReference.path, changeData.id),
                    changeData.data);
              } else {
                // find in doc
                snapshot = snapshotsFindById(docs, changeData.id);
              }
              DocumentChangeSim change = DocumentChangeSim(
                  documentChangeTypeFromString(changeData.type),
                  snapshot,
                  changeData.newIndex,
                  changeData.oldIndex);
              changes.add(change);
            }
            var snapshot = QuerySnapshotSim(docs, changes);
            subscription.add(snapshot);
          }
        }
      });
      var data = FirestoreQueryData()
        ..path = simCollectionReference.path
        ..queryInfo = queryInfo;
      var request =
          simClient.newRequest(methodFirestoreQueryStream, data.toMap());
      var response = await simClient.sendRequest(request);
      if (response is ErrorResponse) {
        throw response.error;
      }

      var responseData = FirestoreQueryStreamResponse()
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
  final DocumentSnapshotSim document;

  @override
  final int newIndex;

  @override
  final int oldIndex;

  DocumentChangeSim(this.type, this.document, this.newIndex, this.oldIndex);
}

class QuerySnapshotSim implements QuerySnapshot {
  final List<DocumentSnapshotSim> simDocs;
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
  QueryInfo queryInfo = QueryInfo();

  CollectionReferenceSim get simCollectionReference => this;
  final FirestoreSim simFirestore;

  @override
  final String path;

  CollectionReferenceSim(this.simFirestore, this.path);

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    var jsonMap = documentDataToJsonMap(DocumentData(data));
    var simClient = await simFirestore.app.simClient;
    var firestoreSetData = FirestoreSetData()
      ..path = path
      ..data = jsonMap;
    var request =
        simClient.newRequest(methodFirestoreAdd, firestoreSetData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
    var firestorePathData = FirestorePathData()
      ..fromMap((response as Response).result as Map<String, dynamic>);
    return DocumentReferenceSim(simFirestore, firestorePathData.path);
  }

  @override
  DocumentReference doc([String path]) =>
      DocumentReferenceSim(simFirestore, url.join(this.path, path));

  @override
  String get id => url.basename(path);

  @override
  DocumentReference get parent =>
      DocumentReferenceSim(simFirestore, url.dirname(path));
}

class FirestoreServiceSim implements FirestoreService {
  FirestoreServiceSim();

  @override
  bool get supportsQuerySelect => true;

  @override
  bool get supportsDocumentSnapshotTime => true;

  @override
  bool get supportsTimestampsInSnapshots => false;
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
      CollectionReferenceSim(this, path);

  @override
  DocumentReference doc(String path) => DocumentReferenceSim(this, path);

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

  DocumentSnapshotSim documentSnapshotFromData(
      FirestoreDocumentSnapshotData documentSnapshotData) {
    var dataMap = documentSnapshotData.data;
    return DocumentSnapshotSim(
        DocumentReferenceSim(this, documentSnapshotData.path),
        dataMap != null,
        documentDataFromJsonMap(this, dataMap),
        createTime: documentSnapshotData.createTime,
        updateTime: documentSnapshotData.updateTime);
    /*
    return documentSnapshotFromDataMap(
        documentSnapshotData.path, documentSnapshotData.data);
        */
  }

  // warning no createTime and update time here
  DocumentSnapshotSim documentSnapshotFromDataMap(
      String path, Map<String, dynamic> map) {
    return DocumentSnapshotSim(DocumentReferenceSim(this, path), map != null,
        documentDataFromJsonMap(this, map),
        createTime: null, updateTime: null);
  }

  @override
  WriteBatch batch() => WriteBatchSim(this);

  @override
  Future runTransaction(
      Function(Transaction transaction) updateFunction) async {
    var simClient = await app.simClient;
    var request = simClient.newRequest(methodFirestoreTransaction, {});
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }

    var responseData = FirestoreTransactionResponseData()
      ..fromMap((response as Response).result as Map<String, dynamic>);
    TransactionSim transactionSim =
        TransactionSim(this, responseData.transactionId);
    try {
      await updateFunction(transactionSim);
      await transactionSim.commit();
    } catch (_) {
      // Make sure to clean up on cancel
      await transactionSim.cancel();
      rethrow;
    }
  }

  Future<DocumentSnapshot> get(FirestoreGetRequestData requestData) async {
    var simClient = await app.simClient;
    var request = simClient.newRequest(methodFirestoreGet, requestData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }

    var map = ((response as Response).result as Map)?.cast<String, dynamic>();

    var documentSnapshotData = FirestoreDocumentSnapshotDataImpl()
      ..fromMap(map);
    return DocumentSnapshotSim(
        DocumentReferenceSim(this, documentSnapshotData.path),
        documentSnapshotData.data != null,
        documentDataFromJsonMap(this, documentSnapshotData.data),
        createTime: documentSnapshotData.createTime,
        updateTime: documentSnapshotData.updateTime);
  }

  @override
  void settings(FirestoreSettings settings) {
    // TODO: implement settings
  }
}

class TransactionSim extends WriteBatchSim implements Transaction {
  final int transactionId;

  TransactionSim(FirestoreSim firestore, this.transactionId) : super(firestore);

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) {
    var requestData = FirestoreGetRequestData()
      ..path = documentRef.path
      ..transactionId = transactionId;
    return firestore.get(requestData);
  }

  @override
  Future commit() async {
    var batchData = FirestoreBatchData()..transactionId = transactionId;
    await batchCommit(methodFirestoreTransactionCommit, batchData);
  }

  Future cancel() async {
    var requestData = FirestoreTransactionCancelRequestData()
      ..transactionId = transactionId;
    var simClient = await firestore.app.simClient;
    var request = simClient.newRequest(
        methodFirestoreTransactionCancel, requestData.toMap());
    var response = await simClient.sendRequest(request);
    if (response is ErrorResponse) {
      throw response.error;
    }
  }
}

class WriteBatchSim extends WriteBatchBase {
  final FirestoreSim firestore;

  WriteBatchSim(this.firestore);

  @override
  Future commit() async {
    var batchData = FirestoreBatchData();
    await batchCommit(methodFirestoreBatch, batchData);
  }

  Future batchCommit(String method, FirestoreBatchData batchData) async {
    for (var operation in operations) {
      if (operation is WriteBatchOperationDelete) {
        batchData.operations.add(BatchOperationDeleteData()
          ..method = methodFirestoreDelete
          ..path = operation.docRef.path);
      } else if (operation is WriteBatchOperationSet) {
        batchData.operations.add(BatchOperationSetData()
          ..method = methodFirestoreSet
          ..path = operation.docRef.path
          ..data = documentDataToJsonMap(operation.documentData)
          ..merge = operation.options?.merge);
      } else if (operation is WriteBatchOperationUpdate) {
        batchData.operations.add(BatchOperationUpdateData()
          ..method = methodFirestoreUpdate
          ..path = operation.docRef.path
          ..data = documentDataToJsonMap(operation.documentData));
      } else {
        throw 'not supported $operation';
      }
    }
    var simClient = await firestore.app.simClient;
    var request = simClient.newRequest(method, batchData.toMap());
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
      readyCompleter = Completer();
      webSocketChannel = await admin.clientFactory.connect(admin.url);
      var simClient = FirebaseSimClient(webSocketChannel);
      var adminInitializeAppData = AdminInitializeAppData()
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
  Firestore firestore() => _firestore ??= FirestoreSim(this);

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
    return AppSim(this, options, name);
  }

  @override
  FirestoreService firestore = FirestoreServiceSim();
}
