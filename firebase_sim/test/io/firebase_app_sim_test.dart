@TestOn('vm')
library;

import 'dart:async';

import 'package:tekartik_common_utils/common_utils_import.dart';
// ignore: unused_import
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  // debugFirebaseSimClient = devTrue;
  // debugFirebaseSimServer = devTrue;
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
    });
    tearDownAll(() async {
      await app.delete();
    });
    test('ping', () async {
      await app.ping();
    });
    test('getAppName', () async {
      expect(app.name, 'test_sim');
      expect(await app.getAppName(), startsWith('test_sim'));
      expect(await app.getAppName(), isNot('test_sim'));
    });
  });
}
