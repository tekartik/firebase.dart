import 'dart:async';

import 'package:tekartik_firebase_rest/src/test/test_setup.dart';
import 'package:tekartik_firebase_rest/src/test/test_setup.dart' as firebase;

export 'package:tekartik_firebase_rest/src/test/test_setup.dart'
    show getContextFromAccessToken, getAppOptionsFromAccessToken;

/// Setup helper
Future<Context?> setup({String? serviceAccountJsonPath}) async {
  return await firebase.setup(
      scopes: firebaseBaseScopes,
      serviceAccountJsonPath: serviceAccountJsonPath);
}
