@TestOn('vm')
library;

import 'package:tekartik_firebase_rest/firebase_rest.dart';

import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_setup.dart';

Future main() async {
  var context = await setup(useEnv: true);

  if (context == null) {
    test('no env setup available', () {});
  } else {
    group('rest', () {
      test('setup', () {
        print('Using firebase project: ${context.options!.projectId}');
      });
      // there is no name on node
      runFirebaseTests(firebaseRest, options: context.options);
    });
  }
}
