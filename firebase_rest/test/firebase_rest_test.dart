library tekartik_firebase_rest.rest_test;

import 'package:http/http.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:tekartik_firebase_rest/src/test/test_setup.dart'
    show Context, firebaseBaseScopes;
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_setup.dart';

Future main() async {
  var context = await setup();
  Context accessTokenContext;

  AppOptions accessTokenAppOptions;
  if (context != null) {
    accessTokenContext = await getContextFromAccessToken(
        context.client, context.accessToken.data,
        scopes: firebaseBaseScopes);
    // expect(accessTokenContext.authClient, isNotNull);

    accessTokenAppOptions = getAppOptionsFromAccessToken(
        Client(), accessTokenContext.accessToken.data,
        projectId: context.options.projectId, scopes: firebaseBaseScopes);
  }
  group('rest', () {
    if (context != null) {
      // there is no name on node
      runApp(firebaseRest, options: context.options);

      test('authClient', () {
        expect(context.authClient, isNotNull);
      });

      group('token', () {
        runApp(
          firebaseRest,
          options: accessTokenAppOptions,
          name: 'access_token',
        );
        test('authClient', () {
          expect(accessTokenContext.authClient, isNotNull);
        });
      });
    }
  }, skip: context == null);
}
