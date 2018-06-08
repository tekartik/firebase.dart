@TestOn('vm')
library tekartik_firebase_sim_io.admin_sim_test;

import 'package:test/test.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';

import 'test_common.dart';

main() async {
  var testContext = await initTestContextSim();
  run(testContext.firebase);
}
