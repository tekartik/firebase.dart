@TestOn('vm')
library tekartik_firebase_sim_io.admin_sim_test;

import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:test/test.dart';

import 'test_common.dart';

main() async {
  var testContext = await initTestContextSim();
  runApp(testContext.firebase);

  group('firebase_sim_client', () {
    FirebaseSimClient simClient;
    setUp(() {
      var client = webSocketChannelFactoryMemory.client
          .connect<String>(testContext.simServer.url);
      simClient = FirebaseSimClient(client);
    });
    tearDown(() async {
      await simClient.close();
    });
    test('initializeApp', () async {
      await simClient.sendRequest(
          methodAdminInitializeApp, {'projectId': 'test', 'name': 'test_name'});
      var name = await simClient.sendRequest(methodAdminGetAppName);
      expect(name, 'test_name');
    });
  });
}
