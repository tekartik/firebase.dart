import 'dart:async';

import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:tekartik_firebase_rest/src/test/test_setup.dart';
import 'package:tekartik_firebase_rest/src/test/test_setup.dart' as firebase;
export 'package:tekartik_firebase_rest/src/test/test_setup.dart'
    show getContextFromAccessToken, getAppOptionsFromAccessToken;

Future<Context> setup() async {
  return await firebase.setup(scopes: firebaseBaseScopes);
}
