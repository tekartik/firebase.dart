@TestOn('vm')
library tekartik_firebase_server_io.firebase_io_test;

import 'dart:async';

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sembast/firebase_sembast.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_firebase_sim_io/firebase_sim_client_io.dart' as sim;
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';
import 'package:test/test.dart';

class TestContext {
  FirebaseSimServer simServer;
  Firebase firebase;
}

// using real websocker
Future<TestContext> initTestContextSimIo() async {
  var testContext = new TestContext();
  testContext.simServer =
      await serve(firebaseSembast, webSocketChannelFactoryIo);
  testContext.firebase = sim.getFirebaseSim(
      clientFactory: webSocketChannelClientFactoryIo,
      url: testContext.simServer.webSocketChannelServer.url);
  return testContext;
}

// memory only
Future<TestContext> initTestContextSim() async {
  var testContext = new TestContext();
  // The server use firebase io
  testContext.simServer =
      await serve(firebaseSembast, webSocketChannelFactoryMemory);
  testContext.firebase = sim.getFirebaseSim(
      clientFactory: webSocketChannelClientFactoryMemory,
      url: testContext.simServer.webSocketChannelServer.url);
  return testContext;
}

close(TestContext testContext) async {
  await testContext.simServer?.close();
}
