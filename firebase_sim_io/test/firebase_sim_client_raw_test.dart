@TestOn('vm')
library;

import 'dart:async';

import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  var testContext = await initTestContextSim();
  var simServer = testContext.simServer;
  runFirebaseTests(testContext.firebase);

  group('firebase_sim_client', () {
    late FirebaseSimClient simClient;
    setUp(() {
      simClient = FirebaseSimClient.connect(simServer.uri,
          webSocketChannelClientFactory: webSocketChannelClientFactoryMemory);
    });
    tearDown(() async {
      await simClient.close();
    });
    test('initializeApp', () async {
      await simClient.sendRequest<void>(FirebaseSimCoreService.serviceName,
          methodAdminInitializeApp, {'projectId': 'test', 'name': 'test_name'});
      var name = await simClient.sendRequest<String>(
          FirebaseSimCoreService.serviceName, methodAdminGetAppName, null);
      expect(name, 'test_name');
    });
  });
}
