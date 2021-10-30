import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';

import 'firebase_rest.dart';

class FirebaseAdminCredentialRestImpl implements FirebaseAdminCredentialRest {
  late ServiceAccountCredentials serviceAccountCredentials;
  final List<String> scopes;
  @override
  AuthClient? authClient;
  @override
  AppOptionsRest? appOptions;
  String? projectId;

  FirebaseAdminCredentialRestImpl.fromServiceAccountJson(
      String serviceAccountJson,
      {List<String>? scopes})
      : scopes = scopes ?? firebaseBaseScopes {
    var jsonData = jsonDecode(serviceAccountJson) as Map;
    projectId = jsonData['project_id']?.toString();
    serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonData);
  }

  Future<FirebaseAdminAccessToken>? _accessToken;

  @override
  Future<FirebaseAdminAccessToken> getAccessToken() =>
      _accessToken ??= () async {
        var client = Client();
        var accessCreds = await obtainAccessCredentialsViaServiceAccount(
            serviceAccountCredentials, scopes, client);
        var accessToken = accessCreds.accessToken;
        authClient = authenticatedClient(client, accessCreds);
        appOptions = AppOptionsRest(client: authClient)..projectId = projectId;
        return FirebaseAdminAccessTokenRest(data: accessToken.data);
      }();
/*

    var authClient = authenticatedClient(client, accessCreds);
    var appOptions = AppOptionsRest(authClient: authClient)
      ..projectId = jsonData['project_id']?.toString();
    var context = Context()
      ..client = client
      ..accessToken = accessToken
      ..authClient = authClient
      ..options = appOptions;
  }

 */
}

FirebaseAdminCredentialRest newFromServiceAccountJson(String serviceAccountJson,
    {List<String>? scopes}) {
  return FirebaseAdminCredentialRestImpl.fromServiceAccountJson(
      serviceAccountJson,
      scopes: scopes);
}
