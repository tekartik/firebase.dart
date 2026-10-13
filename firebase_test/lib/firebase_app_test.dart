library;

import 'package:tekartik_firebase/firebase.dart';
import 'package:test/test.dart';
export 'package:tekartik_firebase/firebase.dart';

void runFirebaseAppTests(
  FirebaseAsync firebaseAsync,
  FirebaseApp Function() getFirebaseApp,
) {
  test('FirebaseApp', () {
    var firebaseApp = getFirebaseApp();
    if (firebaseAsync is Firebase) {
      expect(firebaseApp.isLocal, firebaseAsync.isLocal);
    }
    if (firebaseApp.options.projectId != null) {
      expect(firebaseApp.projectId, firebaseApp.options.projectId);
    }
  });
}
