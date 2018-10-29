@TestOn('vm')
library tekartik_firebase_sim_io.admin_sim_test;

import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_common.dart';

main() async {
  var testContext = await initTestContextSim();
  run(testContext.firebase);

  group('firebase_app_sim', () {
    AppSim app;
    setUpAll(() {
      app = testContext.firebase.initializeApp(name: 'test_sim') as AppSim;
    });
    tearDownAll(() async {
      await app.delete();
    });
    test('ping', () async {
      await app.ping();
    });
    test('getAppName', () async {
      expect(await app.getAppName(), 'test_sim');
    });
  });
}
