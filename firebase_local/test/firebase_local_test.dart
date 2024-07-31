library tekartik_firebase_local.local_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

void main() {
  group('local', () {
    // there is no name on node
    runFirebaseTests(FirebaseLocal(localPath: '.'), options: null);

    test('projectId', () async {
      var firebase = FirebaseLocal();
      var app = await firebase.initializeAppAsync(
          options: AppOptions(projectId: 'test'));
      expect(app.options.projectId, 'test');
      await app.delete();
    });

    test('newFirebaseAppLocal', () async {
      var app = newFirebaseAppLocal();
      expect(app.options.projectId, 'local');
      expect(app.name, '[DEFAULT]');
      await app.delete();

      app = newFirebaseAppLocal(
          name: 'test_name', options: AppOptions(projectId: 'test_prj'));
      expect(app.options.projectId, 'test_prj');
      expect(app.name, 'test_name');
      await app.delete();
    });
  });
}
