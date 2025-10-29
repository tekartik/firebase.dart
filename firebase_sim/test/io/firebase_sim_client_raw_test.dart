@TestOn('vm')
library;

import 'dart:async';

import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server_service.dart';
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
      simClient = FirebaseSimClient.connect(
        simServer.uri,
        webSocketChannelClientFactory: webSocketChannelClientFactoryMemory,
      );
    });
    tearDown(() async {
      await simClient.close();
    });
    test('initializeApp', () async {
      var appId =
          (await simClient.sendRequest<Map>(
                FirebaseSimServerCoreService.serviceName,
                methodAdminInitializeApp,
                {'projectId': 'test', 'name': 'test_name'},
              ))['appId']
              as int;
      var name =
          (await simClient.sendRequest<Map>(
                FirebaseSimServerCoreService.serviceName,
                methodAdminGetAppName,
                {'appId': appId},
              ))['name']
              as String;
      expect(name, isNot('test_name'));
      expect(name, startsWith('test_name'));
    });
  });
}
