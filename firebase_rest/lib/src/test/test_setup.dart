import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:process_run/shell.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart' hide firebaseRest;
import 'package:tekartik_firebase_rest/src/firebase_rest.dart';

export 'package:tekartik_firebase_rest/firebase_rest.dart';

/// Json (if starting with { or path
const _envServiceAccount = 'TEKARTIK_FIREBASE_REST_TEST_SERVICE_ACCOUNT';

String? _envGetServiceAccountJsonOrPath() {
  return shellEnvironment[_envServiceAccount];
}

class FirebaseRestTestContext {
  Client? client;
  AuthClient? authClient;
  AccessToken? accessToken;

  AppOptionsRest? options;

  /// True if it can be used
  bool get valid => authClient != null;
}

@Deprecated('Use FirebaseRestTestContext')
typedef Context = FirebaseRestTestContext;

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

/// Get the FirebaseRestTestContext from a json file or local.service_account.json file
Future<FirebaseRestTestContext> getContext(Client client,
    {List<String>? scopes,
    String? dir,
    String? serviceAccountJsonPath,
    Map? serviceAccountMap,
    bool? useEnv}) async {
  Map serviceAccountFromString(String jsonString) {
    return jsonDecode(jsonString) as Map;
  }

  Map serviceAccountFromPath(String path) {
    try {
      var serviceAccountJsonString = File(path).readAsStringSync();
      return serviceAccountFromString(serviceAccountJsonString);
    } catch (e) {
      throw (StateError('Cannot read $path'));
    }
  }

  Map jsonData;
  if (serviceAccountMap != null) {
    jsonData = serviceAccountMap;
  } else if (useEnv == true) {
    var serviceAccountJsonOrPath = _envGetServiceAccountJsonOrPath();
    if (serviceAccountJsonOrPath == null) {
      throw (StateError('$_envServiceAccount not set'));
    }
    if (serviceAccountJsonOrPath.startsWith('{')) {
      jsonData = serviceAccountFromString(serviceAccountJsonOrPath);
    } else {
      jsonData = serviceAccountFromPath(serviceAccountJsonOrPath);
    }
  } else {
    serviceAccountJsonPath ??=
        join(dir ?? 'test', 'local.service_account.json');
    jsonData = serviceAccountFromPath(serviceAccountJsonPath);
  }

  var creds = ServiceAccountCredentials.fromJson(jsonData);

  var accessCreds = await obtainAccessCredentialsViaServiceAccount(
      creds, scopes ?? firebaseBaseScopes, client);
  var accessToken = accessCreds.accessToken;

  var authClient = authenticatedClient(client, accessCreds);
  var appOptions = AppOptionsRest(client: authClient)
    ..projectId = (jsonData)['project_id']?.toString();
  var context = FirebaseRestTestContext()
    ..client = client
    ..accessToken = accessToken
    ..authClient = authClient
    ..options = appOptions;
  return context;
}

Future<FirebaseRestTestContext> getContextFromAccessCredentials(
    Client client, AccessCredentials accessCredentials,
    {List<String>? scopes}) async {
  var accessToken = accessCredentials.accessToken;

  var authClient = authenticatedClient(client, accessCredentials);
  var appOptions = AppOptionsRest(client: authClient);
  // ..projectId = jsonData['project_id']?.toString();
  var context = FirebaseRestTestContext()
    ..client = client
    ..accessToken = accessToken
    ..authClient = authClient
    ..options = appOptions;
  return context;
}

Future<FirebaseRestTestContext> getContextFromAccessToken(
    Client client, String token,
    {required List<String> scopes}) async {
  // expiry is ignored in request
  var accessToken = AccessToken('Bearer', token, DateTime.now().toUtc());
  var accessCredentials = AccessCredentials(accessToken, null, scopes);
  return getContextFromAccessCredentials(client, accessCredentials);
}

Future<FirebaseRestTestContext?> setup(
    {List<String>? scopes,
    String dir = 'test',
    bool? useEnv,
    String? serviceAccountJsonPath,
    Map? serviceAccountMap}) async {
  var client = Client();
  // Load client info
  try {
    return await getContext(client,
        scopes: scopes,
        dir: dir,
        serviceAccountJsonPath: serviceAccountJsonPath,
        serviceAccountMap: serviceAccountMap,
        useEnv: useEnv);
  } catch (e) {
    client.close();
    print(e);
  }
  return null;
}

/// if [serviceAccountJsonPath] is not set, look for [dir]/local.service_account.json
Future<FirebaseRest?> firebaseRestSetup(
    {List<String>? scopes,
    String dir = 'test',
    Map? serviceAccountMap,
    String? serviceAccountJsonPath}) async {
  var client = Client();
  // Load client info
  try {
    serviceAccountJsonPath ??= join(dir, 'local.service_account.json');

    var serviceAccountJsonString =
        File(serviceAccountJsonPath).readAsStringSync();
    firebaseRest.credential.setApplicationDefault(
        FirebaseAdminCredentialRest.fromServiceAccountJson(
            serviceAccountJsonString,
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
