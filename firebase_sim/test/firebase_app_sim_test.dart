@TestOn('vm')
library;

import 'dart:async';

import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  var testContext = await initTestContextSim();
  run(testContext);

  tearDownAll(() async {
    await close(testContext);
  });
}

void run(TestContext testContext) {
  runFirebaseTests(testContext.firebase);

  group('firebase_app_sim', () {
    late AppSim app;
    setUpAll(() {
      app = testContext.firebase.initializeApp(name: 'test_sim') as AppSim;
      expect(FirebaseApp.instance, app);
      expect(app.name, 'test_sim');
      expect(app.projectId, 'sim');
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
