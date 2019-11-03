import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:tekartik_firebase_rest/src/firebase_rest.dart';

class Context {
  Client client;
  AuthClient authClient;
  AccessToken accessToken;

  AppOptionsRestImpl options;

  /// True if it can be used
  bool get valid => authClient != null;
}

const firebaseGoogleApisUserEmailScope =
    "https://www.googleapis.com/auth/userinfo.email";
const firebaseGoogleApisCloudPlatformScope =
    "https://www.googleapis.com/auth/cloud-platform";
const _firebaseScopes = [
  firebaseGoogleApisCloudPlatformScope,
  firebaseGoogleApisUserEmailScope
];

const firebaseBaseScopes = [
  firebaseGoogleApisCloudPlatformScope,
  firebaseGoogleApisUserEmailScope
];

class ServiceAccount {
  Map jsonData;
  AccessToken accessToken;
}

@deprecated
Future<AccessToken> getAccessToken(Client client) async {
  var serviceAccountJsonPath = join('test', 'local.service_account.json');

  var serviceAccountJsonString =
      File(serviceAccountJsonPath).readAsStringSync();

  var creds = ServiceAccountCredentials.fromJson(serviceAccountJsonString);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, _firebaseScopes, client);

  return accessCreds.accessToken;
}

Future<Context> getContext(Client client,
    {List<String> scopes, String dir}) async {
  var serviceAccountJsonPath =
      join(dir ?? 'test', 'local.service_account.json');

  var serviceAccountJsonString =
      File(serviceAccountJsonPath).readAsStringSync();

  var jsonData = jsonDecode(serviceAccountJsonString);
  var creds = ServiceAccountCredentials.fromJson(jsonData);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, scopes ?? _firebaseScopes, client);
  var accessToken = accessCreds.accessToken;

  var authClient = authenticatedClient(client, accessCreds);
  var appOptions = AppOptionsRestImpl(authClient: authClient)
    ..projectId = jsonData['project_id']?.toString();
  var context = Context()
    ..client = client
    ..accessToken = accessToken
    ..authClient = authClient
    ..options = appOptions;
  return context;
}

Future<Context> setup({List<String> scopes, String dir = 'test'}) async {
  dir ??= 'test';
  var client = Client();
  // Load client info
  try {
    return await getContext(client, scopes: scopes, dir: dir);
  } catch (e) {
    client.close();
    print(e);
    print('Cannot find ${dir}/sample.local.config.yaml');
    print('Make sure to run the test using something like: ');
    print('  pub run build_runner test --fail-on-severe -- -p chrome');
  }
  return null;
}
