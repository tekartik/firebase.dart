library;

import 'package:tekartik_firebase/firebase.dart';
import 'package:test/test.dart';
export 'package:tekartik_firebase/firebase.dart';

void runFirebaseAppTests(
    FirebaseAsync firebaseAsync, FirebaseApp Function() getFirebaseApp) {
  test('FirebaseApp', () {
    var firebaseApp = getFirebaseApp();
    expect(firebaseApp.isLocal, firebaseApp.isLocal);
    expect(firebaseApp.options.projectId, isNotNull);
  });
}
