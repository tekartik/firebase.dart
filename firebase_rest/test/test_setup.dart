import 'dart:async';

import 'package:tekartik_firebase_rest/src/test/test_setup.dart';
import 'package:tekartik_firebase_rest/src/test/test_setup.dart' as firebase;

export 'package:tekartik_firebase_rest/src/test/test_setup.dart'
    show getContextFromAccessToken, getAppOptionsFromAccessToken;

/// Setup helper
Future<FirebaseRestTestContext?> setup(
    {String? serviceAccountJsonPath,
    Map? serviceAccountMap,
    bool? useEnv}) async {
  return await firebase.setup(
      scopes: firebaseBaseScopes,
      serviceAccountJsonPath: serviceAccountJsonPath,
      serviceAccountMap: serviceAccountMap,
      useEnv: useEnv);
}
