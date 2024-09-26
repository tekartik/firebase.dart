import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_firebase_sim_io/firebase_sim_client_io.dart' as sim;
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket_io/web_socket_io.dart';

class TestContext {
  late FirebaseSimServer simServer;
  late Firebase firebase;
}

// using real websocker
Future<TestContext> initTestContextSimIo() async {
  var testContext = TestContext();
  testContext.simServer =
      await serve(FirebaseLocal(), webSocketChannelFactoryIo);
  testContext.firebase = sim.getFirebaseSim(
      clientFactory: webSocketChannelClientFactoryIo,
      url: testContext.simServer.webSocketChannelServer.url);
  return testContext;
}

// memory only
Future<TestContext> initTestContextSim() async {
  var testContext = TestContext();
  // The server use firebase io
  testContext.simServer =
      await serve(FirebaseLocal(), webSocketChannelFactoryMemory);
  testContext.firebase = sim.getFirebaseSim(
      clientFactory: webSocketChannelClientFactoryMemory,
      url: testContext.simServer.webSocketChannelServer.url);
  return testContext;
}

Future close(TestContext testContext) async {
  await testContext.simServer.close();
}
