@TestOn('vm')
library tekartik_firebase_server_io.firestore_sim_io_test;

import 'package:tekartik_firebase_test/firestore_test.dart';
import 'package:test/test.dart';

import 'test_common.dart';

main() async {
  skipConcurrentTransactionTests = true;
  var testContext = await initTestContextSimIo();
  run(testContext.firebase);

  tearDownAll(() async {
    await close(testContext);
  });
}
