import 'package:tekartik_firebase/src/firebase_mock.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';

void main() {
  runFirebaseTests(FirebaseMock());
  runFirebaseTests(FirebaseAdminMock());
}
