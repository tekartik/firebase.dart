import 'dart:async';

import 'package:tekartik_firebase_rest/src/test/test_setup.dart';
import 'package:tekartik_firebase_rest/src/test/test_setup.dart' as firebase;

Future<Context> setup() async {
  return await firebase.setup(scopes: firebaseBaseScopes);
}
