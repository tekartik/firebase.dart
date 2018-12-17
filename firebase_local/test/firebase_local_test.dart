library tekartik_firebase_local.local_test;

import 'package:test/test.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';

void main() {
  group('node', () {
    // there is no name on node
    runApp(FirebaseLocal(localPath: '.'), options: null);
  });
}
