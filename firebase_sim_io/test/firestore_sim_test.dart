@TestOn('vm')
library tekartik_firebase_server_io.firebase_io_test;

import 'package:tekartik_firebase_test/firestore_test.dart';
import 'package:test/test.dart';

import 'test_common.dart';

main() async {
  var testContext = await initTestContextSim();
  run(testContext.firebase);

  tearDownAll(() async {
    await close(testContext);
  });
}
