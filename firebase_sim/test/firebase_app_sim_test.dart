@TestOn('vm')
library;

import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  // debugFirebaseSimClient = debugFirebaseSimServer = devTrue;
  var testContext = await initTestContextSim();
  // Declared first so that it runs last, after the app teardowns.
  tearDownAll(() async {
    await close(testContext);
  });
  run(testContext);
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
      expect(app.name, 'test_sim');
      expect(await app.getAppName(), isNot('test_sim'));
      expect(await app.getAppName(), startsWith('test_sim'));
    });
  });
}
