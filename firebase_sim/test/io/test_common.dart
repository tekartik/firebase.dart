import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';

// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket_io/web_socket_io.dart';

class TestContext {
  late FirebaseSimServer simServer;
  late Firebase firebase;
}

// using real websocker
Future<TestContext> initTestContextSimIo() async {
  var testContext = TestContext();
  testContext.simServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelServerFactoryIo,
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
  );
  testContext.firebase = getFirebaseSim(
    clientFactory: webSocketChannelClientFactoryMemory,
    uri: testContext.simServer.uri,
  );
  return testContext;
}

Future close(TestContext testContext) async {
  await testContext.simServer.close();
}
