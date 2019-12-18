library tekartik_firebase_local.local_test;

import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

void main() {
  group('local', () {
    // there is no name on node
    runApp(FirebaseLocal(localPath: '.'), options: null);
  });
}
