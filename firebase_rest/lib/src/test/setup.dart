import 'dart:async';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart' hide firebaseRest;
import 'package:tekartik_firebase_rest/src/firebase_rest.dart';

export 'package:tekartik_firebase_rest/firebase_rest.dart';

class Context {
  Client? client;
  AuthClient? authClient;
  AccessToken? accessToken;

  AppOptionsRest? options;

  /// True if it can be used
  bool get valid => authClient != null;
}

class ServiceAccount {
  Map? jsonData;
  AccessToken? accessToken;
}

@Deprecated('Use getContext')
Future<AccessToken> getAccessToken(Client client) async {
  var serviceAccountJsonPath = join('test', 'local.service_account.json');

  var serviceAccountJsonString =
      File(serviceAccountJsonPath).readAsStringSync();

  var creds = ServiceAccountCredentials.fromJson(serviceAccountJsonString);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, firebaseBaseScopes, client);

  return accessCreds.accessToken;
}

/// Get the context from a json file or local.service_account.json file
Future<Context> getContext(Client client,
    {List<String>? scopes, String? dir, required Map serviceAccountMap}) async {
  var creds = ServiceAccountCredentials.fromJson(serviceAccountMap);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, scopes ?? firebaseBaseScopes, client);
  var accessToken = accessCreds.accessToken;

  var authClient = authenticatedClient(client, accessCreds);
  var appOptions = AppOptionsRest(client: authClient)
    ..projectId = serviceAccountMap['project_id']?.toString();
  var context = Context()
    ..client = client
    ..accessToken = accessToken
    ..authClient = authClient
    ..options = appOptions;
  return context;
}

Future<Context> getContextFromAccessCredentials(
    Client client, AccessCredentials accessCredentials,
    {List<String>? scopes}) async {
  var accessToken = accessCredentials.accessToken;

  var authClient = authenticatedClient(client, accessCredentials);
  var appOptions = AppOptionsRest(client: authClient);
  // ..projectId = jsonData['project_id']?.toString();
  var context = Context()
    ..client = client
    ..accessToken = accessToken
    ..authClient = authClient
    ..options = appOptions;
  return context;
}

Future<Context> getContextFromAccessToken(Client client, String token,
    {required List<String> scopes}) async {
  // expiry is ignored in request
  var accessToken = AccessToken('Bearer', token, DateTime.now().toUtc());
  var accessCredentials = AccessCredentials(accessToken, null, scopes);
  return getContextFromAccessCredentials(client, accessCredentials);
}

/*
Future<Context> getContextFromJsonAccount(Client client,
    {List<String> scopes, String serviceAccountJsonString}) async {
  var jsonData = jsonDecode(serviceAccountJsonString);
  var creds = ServiceAccountCredentials.fromJson(jsonData);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, scopes ?? _firebaseScopes, client);
  var accessToken = accessCreds.accessToken;

  var authClient = authenticatedClient(client, accessCreds);
  var appOptions = AppOptionsRest(authClient: authClient)
    ..projectId = jsonData['project_id']?.toString();
  var context = Context()
    ..client = client
    ..accessToken = accessToken
    ..authClient = authClient
    ..options = appOptions;
  return context;
}
*/
Future<Context?> setup(
    {List<String>? scopes,
    String dir = 'test',
    required Map serviceAccountMap}) async {
  var client = Client();
  // Load client info
  try {
    return await getContext(client,
        scopes: scopes, dir: dir, serviceAccountMap: serviceAccountMap);
  } catch (e) {
    client.close();
    print(e);
    print('Cannot find $dir/sample.local.config.yaml');
    print('Make sure to run the test using something like: ');
    print('  pub run build_runner test --fail-on-severe -- -p chrome');
  }
  return null;
}

/// if [serviceAccountJsonPath] is not set, look for [dir]/local.service_account.json
Future<FirebaseRest?> firebaseRestSetup(
    {List<String>? scopes,
    String dir = 'test',
    required serviceAccountMap}) async {
  var client = Client();
  // Load client info
  try {
    firebaseRest.credential.setApplicationDefault(
        FirebaseAdminCredentialRest.fromServiceAccountMap(serviceAccountMap,
            scopes: scopes));
    await firebaseRest.credential.applicationDefault()?.getAccessToken();
    return firebaseRest;
  } catch (e) {
    client.close();
    print(e);
    print('Cannot find $dir/sample.local.config.yaml');
    print('Make sure to run the test using something like: ');
    print('  pub run build_runner test --fail-on-severe -- -p chrome');
  }
  return null;
}
