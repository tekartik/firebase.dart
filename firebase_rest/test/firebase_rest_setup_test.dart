@TestOn('vm')
library tekartik_firebase_rest.rest_setup_test;

import 'dart:io';

import 'package:path/path.dart' hide Context;
import 'package:test/test.dart';

import 'test_setup.dart';

Future main() async {
  test('setup', () async {
    var serviceAccountJsonPath = join('test', 'local.service_account.json');
    if (File(serviceAccountJsonPath).existsSync()) {
      var context = await setup(serviceAccountJsonPath: serviceAccountJsonPath);
      expect(context!.accessToken, isNotNull);
    }
  });
}
