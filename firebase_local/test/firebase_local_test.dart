library;

import 'package:tekartik_firebase/firebase_mixin.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

void main() {
  group('local', () {
    // there is no name on node
    runFirebaseTests(FirebaseLocal(localPath: '.'), options: null);

    test('isLocal', () {
      var firebase = FirebaseLocal();
      expect(firebase.isLocal, isTrue);
    });
    test('initialize sync and latest', () {
      FirebaseMixin.latestFirebaseInstanceOrNull = null;
      var firebase = FirebaseLocal();
      var app = firebase.initializeApp(options: AppOptions(projectId: 'test'));
      expect(FirebaseMixin.latestFirebaseInstanceOrNull, app);
    });
    test('projectId', () async {
      var firebase = FirebaseLocal();
      var app = await firebase.initializeAppAsync(
          options: AppOptions(projectId: 'test'));
      expect(app.options.projectId, 'test');
      await app.delete();
    });

    test('newFirebaseAppLocal', () async {
      var app = newFirebaseAppLocal();
      expect(app.isLocal, isTrue);
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
