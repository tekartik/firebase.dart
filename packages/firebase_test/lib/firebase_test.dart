library tekartik_firebase_admin_shim.admin_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:test/test.dart';

void run(Firebase firebase) {
  App app = firebase.initializeApp();

  tearDownAll(() {
    return app.delete();
  });

  runApp(firebase, app);
}

runApp(Firebase firebase, App app) {
  group('Firebase', () {
    test('default app name', () {
      expect(app.name, '[DEFAULT]');
    });

    test('app name', () async {
      App app = firebase.initializeApp(name: "test");
      expect(app.name, 'test');
      await app.delete();
    });

    test('app options', () async {
      App app = firebase.initializeApp(
          options: new AppOptions(projectId: "testProjectId"), name: "test");
      expect(app.name, 'test');
      expect(app.options.projectId, 'testProjectId');
      await app.delete();
    });
  });
}