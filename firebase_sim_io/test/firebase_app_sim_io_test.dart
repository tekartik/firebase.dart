@TestOn('vm')
library;

import 'dart:async';

import 'package:test/test.dart';

import 'firebase_app_sim_test.dart';
import 'test_common.dart';

Future main() async {
  var testContext = await initTestContextSimIo();
  run(testContext);

  tearDownAll(() async {
    await close(testContext);
  });
}
