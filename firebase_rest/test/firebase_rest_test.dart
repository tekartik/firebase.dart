library tekartik_firebase_rest.rest_test;

import 'package:tekartik_firebase_rest/firebase_rest.dart';

import 'package:tekartik_firebase_rest/src/test/test_setup.dart'
    show firebaseRestSetup;
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

Future main() async {
  var firebaseRest = await firebaseRestSetup();

  if (firebaseRest == null) {
    test('no setup available', () {});
  } else {
    group('rest', () {
      // there is no name on node
      runApp(firebaseRest);

      test('authClient', () {
        if (firebaseRest is FirebaseAdminRest) {
          expect(
              (firebaseRest.credential.applicationDefault()
                      as FirebaseAdminCredentialRest)
                  .authClient,
              isNotNull);
        }
      });

      test('admin', () async {
        if (firebaseRest is FirebaseAdminRest) {
          expect(
              (await firebaseRest.credential
                      .applicationDefault()!
                      .getAccessToken())
                  .data,
              isNotNull);
        }
      });
    });
  }
}
