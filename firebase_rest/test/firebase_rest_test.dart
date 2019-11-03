library tekartik_firebase_rest.rest_test;

import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_setup.dart';

Future main() async {
  var context = await setup();
  group('rest', () {
    if (context != null) {
      // there is no name on node
      runApp(firebaseRest, options: context.options);

      test('authClient', () {
        expect(context.authClient, isNotNull);
      });
    }
  }, skip: context == null);
}
