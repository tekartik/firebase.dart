library tekartik_firebase_sembast.firebase_sembast_memory_test;

import 'package:tekartik_firebase_sembast/firebase_sembast.dart';
import 'package:tekartik_firebase_test/firestore_test.dart';

void main() {
  skipConcurrentTransactionTests = true;
  run(firebaseSembastMemory);
}
