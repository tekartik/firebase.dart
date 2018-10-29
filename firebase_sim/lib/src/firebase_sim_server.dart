import 'dart:async';
import 'dart:convert';
import 'dart:core' hide Error;

import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore_common.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/rpc_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_common.dart';
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

// for debugging
@deprecated
set debugSimServerMessage(bool debugMessage) =>
    _debugMessage = debugMessage;
bool _debugMessage = false;

Future<FirebaseSimServer> serve(
    Firebase firebase, WebSocketChannelFactory channelFactory,
    {int port}) async {
  var server = await channelFactory.server.serve<String>(port: port);
  var simServer = FirebaseSimServer(firebase, server);
  return simServer;
}

class FirebaseSimServer {
  int lastAppId = 0;
  final Firebase firebase;
  int lastSubscriptionId = 0;
  int lastTransactionId = 0;
  final transactionLock = Lock();

  final List<FirebaseSimServerClient> clients = [];
  final WebSocketChannelServer<String> webSocketChannelServer;

  String get url => webSocketChannelServer.url;

  FirebaseSimServer(this.firebase, this.webSocketChannelServer) {
    webSocketChannelServer.stream.listen((clientChannel) {
      var client = FirebaseSimServerClient(this, clientChannel);
      clients.add(client);
    });
  }

  Future close() async {
    // stop allowing clients
    await webSocketChannelServer.close();
    // Close existing clients
    for (var client in clients) {
      await client.close();
    }
  }
}

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
    if (_debugMessage) {
      print(message);
    }
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
  final FirebaseSimServer server;
  final WebSocketChannel<String> webSocketChannel;
  App app;
  int appId;
  Completer transactionCompleter;

  final Map<int, SimSubscription> subscriptions = {};

  FirebaseSimServerClient(this.server, this.webSocketChannel) {
    init();
  }

  @override
  Future close() async {
    // Close any pending transaction
    if (transactionCompleter != null) {
      if (!transactionCompleter.isCompleted) {
        transactionCompleter.completeError('database closed');
      }
    }
    await closeMixin();
    List<SimSubscription> subscriptions = this.subscriptions.values.toList();
    for (var subscription in subscriptions) {
      await cancelSubscription(subscription);
    }
  }

  void handleRequest(Request request) async {
    try {
      if (request.method == methodPing) {
        var response = Response(request.id, null);
        sendMessage(response);
      } else if (request.method == methodAdminInitializeApp) {
        await handleAdminInitializeApp(request);
      } else if (request.method == methodFirestoreSet) {
        await handleFirestoreSetRequest(request);
      } else if (request.method == methodFirestoreUpdate) {
        await handleFirestoreUpdateRequest(request);
      } else if (request.method == methodFirestoreAdd) {
        await handleFirestoreAddRequest(request);
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
      } else if (request.method == methodFirestoreTransaction) {
        await handleFirestoreTransaction(request);
      } else if (request.method == methodFirestoreTransactionCommit) {
        await handleFirestoreTransactionCommit(request);
      } else if (request.method == methodFirestoreTransactionCancel) {
        await handleFirestoreTransactionCancel(request);
      } else if (request.method == methodFirestoreDelete) {
        await handleFirestoreDeleteRequest(request);
      } else {
        var errorResponse = ErrorResponse(
            request.id,
            Error(errorCodeMethodNotFound,
                "unsupported method ${request.method}"));
        sendMessage(errorResponse);
      }
    } catch (e, st) {
      print(e);
      print(st);
      var errorResponse = ErrorResponse(
          request.id,
          Error(errorCodeExceptionThrown,
              "${e} thrown from method ${request.method}\n$st"));
      sendMessage(errorResponse);
    }
  }

  Future handleFirestoreDeleteRequest(Request request) async {
    var response = Response(request.id, null);

    var firestoreDeleteData = FirestorePathData()
      ..fromMap(requestParams(request));

    await server.transactionLock.synchronized(() async {
      await app.firestore().doc(firestoreDeleteData.path).delete();
    });

    sendMessage(response);
  }

  Future handleFirestoreAddRequest(Request request) async {
    var firestoreSetData = FirestoreSetData()..fromMap(requestParams(request));
    var documentData =
        documentDataFromJsonMap(app.firestore(), firestoreSetData.data);

    await server.transactionLock.synchronized(() async {
      var docRef = await app
          .firestore()
          .collection(firestoreSetData.path)
          .add(documentData.asMap());

      var response = Response(
          request.id, (FirestorePathData()..path = docRef.path).toMap());
      sendMessage(response);
    });
  }

  Future handleFirestoreUpdateRequest(Request request) async {
    var firestoreSetData = FirestoreSetData()..fromMap(requestParams(request));
    var documentData =
        documentDataFromJsonMap(app.firestore(), firestoreSetData.data);

    await server.transactionLock.synchronized(() async {
      await app
          .firestore()
          .doc(firestoreSetData.path)
          .update(documentData.asMap());
    });

    var response = Response(request.id, null);
    sendMessage(response);
  }

  Future handleFirestoreSetRequest(Request request) async {
    var firestoreSetData = FirestoreSetData()..fromMap(requestParams(request));
    var documentData =
        documentDataFromJsonMap(app.firestore(), firestoreSetData.data);
    SetOptions options;
    if (firestoreSetData.merge != null) {
      options = SetOptions(merge: firestoreSetData.merge);
    }

    await server.transactionLock.synchronized(() async {
      await app
          .firestore()
          .doc(firestoreSetData.path)
          .set(documentData.asMap(), options);
    });

    var response = Response(request.id, null);
    sendMessage(response);
  }

  DocumentReference requestDocumentReference(Request request) {
    var firestorePathData = FirestorePathData()
      ..fromMap(requestParams(request));
    var ref = app.firestore().doc(firestorePathData.path);
    return ref;
  }

  Future handleFirestoreGet(Request request) async {
    var firestoreGetRequesthData = FirestoreGetRequestData()
      ..fromMap(requestParams(request));
    var ref = requestDocumentReference(request);
    var transactionId = firestoreGetRequesthData.transactionId;

    // Current transaction, read as is
    DocumentSnapshot documentSnapshot;
    if (transactionId == server.lastTransactionId) {
      documentSnapshot = await ref.get();
    } else {
      // otherwise lock
      await server.transactionLock.synchronized(() async {
        documentSnapshot = await ref.get();
      });
    }

    /*

Map<String, dynamic> snapshotToJsonMap(DocumentSnapshot snapshot) {
  if (snapshot?.exists == true) {
    var map = documentDataToJsonMap(documentDataFromSnapshot(snapshot));
    if (snapshot.createTime != null) {
      map[createTimeKey] = snapshot.createTime;
      map[updateTimeKey] = snapshot.updateTime;
    }
    return map;
  } else {
    return null;
  }
}
     */
    var snapshotData = DocumentGetSnapshotData.fromSnapshot(documentSnapshot);

    // Get
    var response = Response(request.id, snapshotData.toMap());

    sendMessage(response);
  }

  Future handleFirestoreGetStream(Request request) async {
    var pathData = FirestorePathData()..fromMap(requestParams(request));
    var ref = app.firestore().doc(pathData.path);
    int streamId = ++server.lastSubscriptionId;

    await server.transactionLock.synchronized(() async {
      // ignore: cancel_subscriptions
      StreamSubscription<DocumentSnapshot> streamSubscription =
          ref.onSnapshot().listen((DocumentSnapshot snapshot) {
        // delayed to make sure the response was send already
        Future.value().then((_) async {
          var data = DocumentGetSnapshotData.fromSnapshot(snapshot);
          data.streamId = streamId;

          var notification =
              Notification(methodFirestoreGetStream, data.toMap());
          sendMessage(notification);
        });
      });

      var data = FirestoreQueryStreamResponse();
      subscriptions[streamId] = SimSubscription(streamId, streamSubscription);
      data.streamId = streamId;

      // Get
      var response = Response(request.id, data.toMap());

      sendMessage(response);
    });
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
    var cancelData = FirestoreQueryStreamCancelData()
      ..fromMap(requestParams(request));
    int streamId = cancelData.streamId;

    var simSubscription = subscriptions[streamId];
    if (simSubscription != null) {
      await cancelSubscription(simSubscription);
      var response = Response(request.id, null);
      sendMessage(response);
    } else {
      var errorResponse = ErrorResponse(
          request.id,
          Error(errorCodeSubscriptionNotFound,
              "subscription $streamId not found method ${request.method}"));
      sendMessage(errorResponse);
    }
  }

  Future handleFirestoreQueryStream(Request request) async {
    var queryData = FirestoreQueryData()
      ..firestoreFromMap(app.firestore(), requestParams(request));

    await server.transactionLock.synchronized(() async {
      Query query = await getQuery(queryData);
      int streamId = ++server.lastSubscriptionId;

      // ignore: cancel_subscriptions
      StreamSubscription<QuerySnapshot> streamSubscription =
          query.onSnapshot().listen((QuerySnapshot querySnapshot) {
        // delayed to make sure the response was send already
        Future.value().then((_) async {
          var data = FirestoreQuerySnapshotData();
          data.streamId = streamId;
          data.list = <DocumentSnapshotData>[];
          for (DocumentSnapshot doc in querySnapshot.docs) {
            data.list.add(DocumentSnapshotData.fromSnapshot(doc));
          }
          // Changes
          data.changes = <DocumentChangeData>[];
          for (var change in querySnapshot.documentChanges) {
            var documentChangeData = DocumentChangeData()
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
              Notification(methodFirestoreQueryStream, data.toMap());
          sendMessage(notification);
        });
      });

      var data = FirestoreQueryStreamResponse();
      subscriptions[streamId] = SimSubscription(streamId, streamSubscription);
      data.streamId = streamId;

      // Get
      var response = Response(request.id, data.toMap());

      sendMessage(response);
    });
  }

  // Batch
  Future handleFirestoreBatch(Request request) async {
    var batchData = FirestoreBatchData()
      ..firestoreFromMap(app.firestore(), requestParams(request));

    await server.transactionLock.synchronized(() async {
      await _handleFirestoreBatch(batchData, request);
    });
  }

  Future _handleFirestoreBatch(
      FirestoreBatchData batchData, Request request) async {
    var batch = app.firestore().batch();
    for (var item in batchData.operations) {
      if (item is BatchOperationDeleteData) {
        batch.delete(app.firestore().doc(item.path));
      } else if (item is BatchOperationSetData) {
        batch.set(
            app.firestore().doc(item.path),
            documentDataFromJsonMap(app.firestore(), item.data)?.asMap(),
            item.merge != null ? SetOptions(merge: item.merge) : null);
      } else if (item is BatchOperationUpdateData) {
        batch.update(app.firestore().doc(item.path),
            documentDataFromJsonMap(app.firestore(), item.data)?.asMap());
      } else {
        throw 'not supported ${item}';
      }
    }
    await batch.commit();

    var response = Response(request.id, {});

    sendMessage(response);
  }

  // Transaction
  Future handleFirestoreTransaction(Request request) async {
    var responseData = FirestoreTransactionResponseData()
      ..transactionId = ++server.lastTransactionId;

    // start locking but don't wait
    server.transactionLock.synchronized(() async {
      transactionCompleter = Completer();
      await transactionCompleter.future;
      transactionCompleter = null;
    });
    var response = Response(request.id, responseData.toMap());

    sendMessage(response);
  }

  Future handleFirestoreTransactionCommit(Request request) async {
    var batchData = FirestoreBatchData()
      ..firestoreFromMap(app.firestore(), requestParams(request));

    if (batchData.transactionId == server.lastTransactionId) {
      try {
        await _handleFirestoreBatch(batchData, request);
      } finally {
        // terminate transaction
        transactionCompleter.complete();
      }
    } else {
      await server.transactionLock.synchronized(() async {
        await _handleFirestoreBatch(batchData, request);
      });
    }
  }

  Future handleFirestoreTransactionCancel(Request request) async {
    var requestData = FirestoreTransactionCancelRequestData()
      ..fromMap(requestParams(request));

    if (requestData.transactionId == server.lastTransactionId) {
      // terminate transaction
      transactionCompleter.complete();
    }
    var response = Response(request.id, {});

    sendMessage(response);
  }

  Future handleFirestoreQuery(Request request) async {
    var queryData = FirestoreQueryData()
      ..firestoreFromMap(app.firestore(), requestParams(request));
    Query query = await getQuery(queryData);

    await server.transactionLock.synchronized(() async {
      var querySnapshot = await query.get();

      var data = FirestoreQuerySnapshotData();
      data.list = <DocumentSnapshotData>[];
      for (DocumentSnapshot doc in querySnapshot.docs) {
        data.list.add(DocumentSnapshotData.fromSnapshot(doc));
      }

      // Get
      var response = Response(request.id, data.toMap());

      sendMessage(response);
    });
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
            isLessThanOrEqualTo: where.isLessThanOrEqualTo,
            isGreaterThan: where.isGreaterThan,
            isGreaterThanOrEqualTo: where.isGreaterThanOrEqualTo,
            arrayContains: where.arrayContains,
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
    var response = Response(request.id, null);

    var adminInitializeAppData = AdminInitializeAppData()
      ..fromMap(requestParams(request));
    var options = AppOptions(
      projectId: adminInitializeAppData.projectId,
    );
    app = server.firebase
        .initializeApp(options: options, name: adminInitializeAppData.name);
    // app.firestore().settings(FirestoreSettings(timestampsInSnapshots: true));
    // var snapshot = app.firestore().doc(firestoreSetData.path).get();

    sendMessage(response);
  }
}
