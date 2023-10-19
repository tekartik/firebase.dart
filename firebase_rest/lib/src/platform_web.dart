@Deprecated('use firebase_rest_io')
import 'package:tekartik_firebase_rest/firebase_rest.dart';

FirebaseAdminCredentialRest newFromServiceAccountJson(String serviceAccountJson,
        {List<String>? scopes}) =>
    throw UnsupportedError('newFromServiceAccountJson io only');
FirebaseAdminCredentialRest newFromServiceAccountMap(Map serviceAccountMap,
        {List<String>? scopes}) =>
    throw UnsupportedError('newFromServiceAccountMap io only');
