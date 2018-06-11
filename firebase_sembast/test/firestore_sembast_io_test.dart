@TestOn('vm')
library tekartik_firebase_sembast.firebase_io_test;

import 'package:tekartik_firebase_sembast/firebase_sembast_io.dart';
import 'package:tekartik_firebase_test/firestore_test.dart';
import 'package:test/test.dart';

void main() {
  skipConcurrentTransactionTests = true;
  run(firebaseSembastIo);
}
