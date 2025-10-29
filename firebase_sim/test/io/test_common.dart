import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';

// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket_io/web_socket_io.dart';

class TestContext {
  late FirebaseSimServer simServer;
  late FirebaseSim firebase;
  Future<void> close() async {
    await simServer.close();
    await firebase.close();
  }
}

// using real websocker
Future<TestContext> initTestContextSimIo({int? port}) async {
  var testContext = TestContext();
  testContext.simServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelServerFactoryIo,
    port: port,
  );
  testContext.firebase = getFirebaseSim(
    clientFactory: webSocketChannelClientFactoryIo,
    uri: testContext.simServer.uri,
  );
  return testContext;
}

// memory only
Future<TestContext> initTestContextSim() async {
  var testContext = TestContext();
  // The server use firebase io
  testContext.simServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelServerFactoryMemory,
    port: 0,
  );
  testContext.firebase = getFirebaseSim(
    clientFactory: webSocketChannelClientFactoryMemory,
    uri: testContext.simServer.uri,
  );
  return testContext;
}

Future close(TestContext testContext) async {
  await testContext.close();
}
