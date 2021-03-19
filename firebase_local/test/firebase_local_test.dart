library tekartik_firebase_local.local_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

void main() {
  group('local', () {
    // there is no name on node
    runApp(FirebaseLocal(localPath: '.'), options: null);

    test('projectId', () async {
      var firebase = FirebaseLocal();
      var app = await firebase.initializeAppAsync(
          options: AppOptions(projectId: 'test'));
      expect(app.options!.projectId, 'test');
      await app.delete();
    });
  });
}
