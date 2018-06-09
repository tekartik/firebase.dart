import 'dart:async';
import 'dart:convert';
import 'dart:core' hide Error;

import 'package:meta/meta.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore_common.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_firebase_sim/rpc_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_common.dart';
import 'package:tekartik_web_socket/web_socket.dart';

abstract class FirebaseSimMixin {
  WebSocketChannel<String> get webSocketChannel;

  // default
  // check overrides if this changes
  Future close() async {
    await closeMixin();
  }

  Future closeMixin() async {
    await webSocketChannel.sink.close();
  }

  void sendMessage(Message message) {
    webSocketChannel.sink.add(json.encode(message.toMap()));
  }

  // called internally
  @protected
  void init() {
    webSocketChannel.stream.listen((String data) {
      var message = Message.parseMap(json.decode(data) as Map<String, dynamic>);
      handleMessage(message);
    });
  }

  void handleMessage(Message message);
}

class SimSubscription<T> {
  final int id;
  final StreamSubscription<T> firestoreSubscription;

  SimSubscription(this.id, this.firestoreSubscription);
}

class FirebaseSimServerClient extends Object with FirebaseSimMixin {
  final FirebaseSimServer simServer;
  final WebSocketChannel<String> webSocketChannel;
  App app;
  int appId;
  int lastSubscriptionId = 0;

  final Map<int, SimSubscription> subscriptions = {};

  FirebaseSimServerClient(this.simServer, this.webSocketChannel) {
    init();
  }

  @override
  Future close() async {
    await closeMixin();
    List<SimSubscription> subscriptions = this.subscriptions.values.toList();
    for (var subscription in subscriptions) {
      await cancelSubscription(subscription);
    }
  }

  void handleRequest(Request request) async {
    try {
      if (request.method == methodPing) {
        var response = new Response(request.id, null);
        sendMessage(response);
      } else if (request.method == methodAdminInitializeApp) {
        await handleAdminInitializeApp(request);
      } else if (request.method == methodFirestoreSet) {
        var firestoreSetData = new FirestoreSetData()
          ..fromMap(requestParams(request));
        var documentData =
            documentDataFromJsonMap(app.firestore(), firestoreSetData.data);
        SetOptions options;
        if (firestoreSetData.merge != null) {
          options = new SetOptions(merge: firestoreSetData.merge);
        }
        await app
            .firestore()
            .doc(firestoreSetData.path)
            .set(documentData.asMap(), options);

        var response = new Response(request.id, null);
        sendMessage(response);
      } else if (request.method == methodFirestoreUpdate) {
        var firestoreSetData = new FirestoreSetData()
          ..fromMap(requestParams(request));
        var documentData =
            documentDataFromJsonMap(app.firestore(), firestoreSetData.data);
        await app
            .firestore()
            .doc(firestoreSetData.path)
            .update(documentData.asMap());

        var response = new Response(request.id, null);
        sendMessage(response);
      } else if (request.method == methodFirestoreAdd) {
        var firestoreSetData = new FirestoreSetData()
          ..fromMap(requestParams(request));
        var documentData =
            documentDataFromJsonMap(app.firestore(), firestoreSetData.data);
        var docRef = await app
            .firestore()
            .collection(firestoreSetData.path)
            .add(documentData.asMap());

        var response = new Response(
            request.id, (new FirestorePathData()..path = docRef.path).toMap());
        sendMessage(response);
      } else if (request.method == methodFirestoreGet) {
        await handleFirestoreGet(request);
      } else if (request.method == methodFirestoreGetStream) {
        await handleFirestoreGetStream(request);
      } else if (request.method == methodFirestoreQuery) {
        await handleFirestoreQuery(request);
      } else if (request.method == methodFirestoreQueryStream) {
        await handleFirestoreQueryStream(request);
      } else if (request.method == methodFirestoreQueryStreamCancel) {
        await handleFirestoreQueryStreamCancel(request);
      } else if (request.method == methodFirestoreBatch) {
        await handleFirestoreBatch(request);
      } else if (request.method == methodFirestoreDelete) {
        // Delete
        var response = new Response(request.id, null);

        var firestoreDeleteData = new FirestorePathData()
          ..fromMap(requestParams(request));
        await app.firestore().doc(firestoreDeleteData.path).delete();

        sendMessage(response);
      } else {
        var errorResponse = new ErrorResponse(
            request.id,
            new Error(errorCodeMethodNotFound,
                "unsupported method ${request.method}"));
        sendMessage(errorResponse);
      }
    } catch (e, st) {
      print(e);
      print(st);
      var errorResponse = new ErrorResponse(
          request.id,
          new Error(errorCodeExceptionThrown,
              "${e} thrown from method ${request.method}\n$st"));
      sendMessage(errorResponse);
    }
  }

  DocumentReference requestDocumentReference(Request request) {
    var firestorePathData = new FirestorePathData()
      ..fromMap(requestParams(request));
    var ref = app.firestore().doc(firestorePathData.path);
    return ref;
  }

  Future handleFirestoreGet(Request request) async {
    var ref = requestDocumentReference(request);
    var documentSnapshot = await ref.get();

    var data = documentDataFromSnapshot(documentSnapshot);
    var snapshotData = new DocumentGetSnapshotData()
      ..path = documentSnapshot.ref.path
      ..data = documentDataToJsonMap(data);

    // Get
    var response = new Response(request.id, snapshotData.toMap());

    sendMessage(response);
  }

  Future handleFirestoreGetStream(Request request) async {
    var pathData = new FirestorePathData()..fromMap(requestParams(request));
    var ref = app.firestore().doc(pathData.path);
    int streamId = ++lastSubscriptionId;

    // ignore: cancel_subscriptions
    StreamSubscription<DocumentSnapshot> streamSubscription =
        ref.onSnapshot().listen((DocumentSnapshot snapshot) {
      // delayed to make sure the response was send already
      new Future.value().then((_) async {
        var data = new DocumentGetSnapshotData();
        data.streamId = streamId;
        data.path = ref.path;

        var docData = documentDataFromSnapshot(snapshot);
        data.data = documentDataToJsonMap(docData);

        var notification =
            new Notification(methodFirestoreGetStream, data.toMap());
        sendMessage(notification);
      });
    });

    var data = new FirestoreQueryStreamResponse();
    subscriptions[streamId] = new SimSubscription(streamId, streamSubscription);
    data.streamId = streamId;

    // Get
    var response = new Response(request.id, data.toMap());

    sendMessage(response);
  }

  Future cancelSubscription(SimSubscription simSubscription) async {
    // remove right away
    if (subscriptions.containsKey(simSubscription.id)) {
      subscriptions.remove(simSubscription.id);
      await simSubscription.firestoreSubscription.cancel();
    }
  }

  // Cancel subscription
  Future handleFirestoreQueryStreamCancel(Request request) async {
    var cancelData = new FirestoreQueryStreamCancelData()
      ..fromMap(requestParams(request));
    int streamId = cancelData.streamId;

    var simSubscription = subscriptions[streamId];
    if (simSubscription != null) {
      await cancelSubscription(simSubscription);
      var response = new Response(request.id, null);
      sendMessage(response);
    } else {
      var errorResponse = new ErrorResponse(
          request.id,
          new Error(errorCodeSubscriptionNotFound,
              "subscription $streamId not found method ${request.method}"));
      sendMessage(errorResponse);
    }
  }

  Future handleFirestoreQueryStream(Request request) async {
    var queryData = new FirestoreQueryData()
      ..firestoreFromMap(app.firestore(), requestParams(request));
    Query query = await getQuery(queryData);
    int streamId = ++lastSubscriptionId;

    // ignore: cancel_subscriptions
    StreamSubscription<QuerySnapshot> streamSubscription =
        query.onSnapshot().listen((QuerySnapshot querySnapshot) {
      // delayed to make sure the response was send already
      new Future.value().then((_) async {
        var data = new FirestoreQuerySnapshotData();
        data.streamId = streamId;
        data.list = <DocumentSnapshotData>[];
        for (DocumentSnapshot doc in querySnapshot.docs) {
          var docData = documentDataFromSnapshot(doc);
          data.list.add(new DocumentSnapshotData()
            ..path = doc.ref.path
            ..data = documentDataToJsonMap(docData));
        }
        // Changes
        data.changes = <DocumentChangeData>[];
        for (var change in querySnapshot.documentChanges) {
          var documentChangeData = new DocumentChangeData()
            ..id = change.document.ref.id
            ..type = documentChangeTypeToString(change.type)
            ..newIndex = change.newIndex
            ..oldIndex = change.oldIndex;
          // need data?
          var path = change.document.ref.path;

          _find() {
            for (var doc in querySnapshot.docs) {
              if (doc.ref.path == path) {
                return true;
              }
            }
            return false;
          }

          if (!_find()) {
            documentChangeData.data = documentDataToJsonMap(
                documentDataFromSnapshot(change.document));
          }
          data.changes.add(documentChangeData);
        }
        var notification =
            new Notification(methodFirestoreQueryStream, data.toMap());
        sendMessage(notification);
      });
    });

    var data = new FirestoreQueryStreamResponse();
    subscriptions[streamId] = new SimSubscription(streamId, streamSubscription);
    data.streamId = streamId;

    // Get
    var response = new Response(request.id, data.toMap());

    sendMessage(response);
  }

  // Cancel subscription
  Future handleFirestoreBatch(Request request) async {
    var batchData = new FirestoreBatchData()
      ..firestoreFromMap(app.firestore(), requestParams(request));

    var batch = app.firestore().batch();
    for (var item in batchData.operations) {
      if (item is BatchOperationDeleteData) {
        batch.delete(app.firestore().doc(item.path));
      } else if (item is BatchOperationSetData) {
        batch.set(
            app.firestore().doc(item.path),
            documentDataFromJsonMap(app.firestore(), item.data)?.asMap(),
            item.merge != null ? new SetOptions(merge: item.merge) : null);
      } else if (item is BatchOperationUpdateData) {
        batch.update(app.firestore().doc(item.path),
            documentDataFromJsonMap(app.firestore(), item.data)?.asMap());
      } else {
        throw 'not supported ${item}';
      }
    }
    await batch.commit();

    var response = new Response(request.id, {});

    sendMessage(response);
  }

  Future handleFirestoreQuery(Request request) async {
    var queryData = new FirestoreQueryData()
      ..firestoreFromMap(app.firestore(), requestParams(request));
    Query query = await getQuery(queryData);

    var querySnapshot = await query.get();

    var data = new FirestoreQuerySnapshotData();
    data.list = <DocumentSnapshotData>[];
    for (DocumentSnapshot doc in querySnapshot.docs) {
      var docData = documentDataFromSnapshot(doc);
      data.list.add(new DocumentSnapshotData()
        ..path = doc.ref.path
        ..data = documentDataToJsonMap(docData));
    }

    // Get
    var response = new Response(request.id, data.toMap());

    sendMessage(response);
  }

  Future<Query> getQuery(FirestoreQueryData queryData) async {
    var collectionPath = queryData.path;

    Query query = app.firestore().collection(collectionPath);

    // Handle param
    var queryInfo = queryData.queryInfo;
    if (queryInfo != null) {
      // Select
      if (queryInfo.selectKeyPaths != null) {
        query = query.select(queryInfo.selectKeyPaths);
      }

      // limit
      if (queryInfo.limit != null) {
        query = query.limit(queryInfo.limit);
      }

      // order
      for (var orderBy in queryInfo.orderBys) {
        query = query.orderBy(orderBy.fieldPath,
            descending: orderBy.ascending == false);
      }

      // where
      for (var where in queryInfo.wheres) {
        query = query.where(where.fieldPath,
            isEqualTo: where.isEqualTo,
            isLessThan: where.isLessThan,
            isLessThanOrEqualTo: where.isGreaterThanOrEqualTo,
            isGreaterThan: where.isGreaterThan,
            isGreaterThanOrEqualTo: where.isGreaterThanOrEqualTo,
            isNull: where.isNull);
      }

      if (queryInfo.startLimit != null) {
        // get it
        DocumentSnapshot snapshot;
        if (queryInfo.startLimit.documentId != null) {
          snapshot = await app
              .firestore()
              .collection(collectionPath)
              .doc(queryInfo.startLimit.documentId)
              .get();
        }
        if (queryInfo.startLimit.inclusive == true) {
          query = query.startAt(
              snapshot: snapshot, values: queryInfo.startLimit.values);
        } else {
          query = query.startAfter(
              snapshot: snapshot, values: queryInfo.startLimit.values);
        }
      }
      if (queryInfo.endLimit != null) {
        // get it
        DocumentSnapshot snapshot;
        if (queryInfo.endLimit.documentId != null) {
          snapshot = await app
              .firestore()
              .collection(collectionPath)
              .doc(queryInfo.endLimit.documentId)
              .get();
        }
        if (queryInfo.endLimit.inclusive == true) {
          query = query.endAt(
              snapshot: snapshot, values: queryInfo.endLimit.values);
        } else {
          query = query.endBefore(
              snapshot: snapshot, values: queryInfo.endLimit.values);
        }
      }
    }
    return query;
  }

  @override
  void handleMessage(message) {
    if (message is Request) {
      handleRequest(message);
    }
  }

  handleAdminInitializeApp(Request request) async {
    var response = new Response(request.id, null);

    var adminInitializeAppData = new AdminInitializeAppData()
      ..fromMap(requestParams(request));
    var options = new AppOptions(
      projectId: adminInitializeAppData.projectId,
    );
    app = simServer.firebase
        .initializeApp(options: options, name: adminInitializeAppData.name);
    // var snapshot = app.firestore().doc(firestoreSetData.path).get();

    sendMessage(response);
  }
}
