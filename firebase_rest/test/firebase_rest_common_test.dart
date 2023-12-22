library tekartik_firebase_rest.rest_common_test;

import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:test/test.dart';

Future main() async {
  test('setup', () async {
    var serviceAccountMap = {
      'type': 'service_account',
      'project_id': 'xxx',
      'private_key_id': 'yyy',
      'private_key': 'zzz',
      'client_email': 'aaa',
      'client_id': 'bbbb',
      'auth_uri': 'ccc',
      'token_uri': 'ddd',
      'auth_provider_x509_cert_url': 'eee',
      'client_x509_cert_url': 'fff'
    };
    var firebaseAdmin = firebaseRest as FirebaseAdmin;
    try {
      firebaseAdmin.credential.setApplicationDefault(
          FirebaseAdminCredentialRest.fromServiceAccountMap(
        serviceAccountMap,
        //    scopes: scopes
      ));
      print(firebaseAdmin.credential.applicationDefault());
      await firebaseAdmin.credential.applicationDefault()?.getAccessToken();
    } catch (_) {}
  });
}
