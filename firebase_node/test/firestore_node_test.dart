@TestOn('node')
library tekartik_firebase_server_node.admin_test;

import 'package:test/test.dart';
import 'package:tekartik_firebase_node/firebase_node.dart';
import 'package:tekartik_firebase_test/firestore_test.dart';

void main() {
  // Temp skipping transaction test
  skipConcurrentTransactionTests = true;

  run(firebaseNode);
}
