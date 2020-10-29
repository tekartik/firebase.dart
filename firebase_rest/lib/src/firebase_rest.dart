import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart'; // ignore: implementation_imports
import 'package:meta/meta.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:http/http.dart';

String get _defaultAppName => firebaseAppNameDefault;

/// The app options to use for REST app initialization.
abstract class AppOptionsRest extends AppOptions {
  /// Create a new options object.
  factory AppOptionsRest({@required AuthClient authClient}) =>
      AppOptionsRestImpl(authClient: authClient);
}

var firebaseRest = FirebaseRestImpl();

// const String googleApisAuthDatastoreScope =
//    'https://www.googleapis.com/auth/datastore';
const String googleApisAuthCloudPlatformScope =
    'https://www.googleapis.com/auth/cloud-platform';

class AppOptionsRestImpl extends AppOptions implements AppOptionsRest {
  final AuthClient authClient;

  AppOptionsRestImpl({@required this.authClient});
}

class FirebaseRestImpl
    with FirebaseMixin
    implements FirebaseRest, FirebaseAdmin {
  @override
  App initializeApp({AppOptions options, String name}) {
    name ??= _defaultAppName;
    var impl = AppRestImpl(
      name: name,
      firebaseRest: this,
      options: options ??
          (credential.applicationDefault() as FirebaseAdminCredentialRestImpl)
              .appOptions,
    );
    _apps[impl.name] = impl;
    return impl;
  }

  @override
  Future<App> initializeAppAsync({AppOptions options, String name}) async {
    var app = initializeApp(options: options, name: name);
    // initialize client
    await credential.applicationDefault()?.getAccessToken();
    return app;
  }

  final _apps = <String, AppRestImpl>{};

  @override
  App app({String name}) {
    name ??= _defaultAppName;
    return _apps[name];
  }

  FirebaseAdminCredentialServiceRest _credentialServiceRest;
  @override
  FirebaseAdminCredentialService get credential =>
      _credentialServiceRest ??= FirebaseAdminCredentialServiceRest(this);
}

FirebaseRestImpl _impl;
FirebaseRestImpl get impl => _impl ??= FirebaseRestImpl();

class AppRestImpl with FirebaseAppMixin implements AppRest {
  final FirebaseRestImpl firebaseRest;

  @override
  final AppOptions options;

  bool deleted = false;
  @override
  String name;

  AppRestImpl(
      {@required this.firebaseRest, @required this.options, this.name}) {
    name ??= _defaultAppName;
  }

  @override
  Future<void> delete() async {
    deleted = true;
    await closeServices();
  }

  @override
  AuthClient get authClient => (options as AppOptionsRestImpl)?.authClient;
}

class FirebaseAdminAccessTokenRest implements FirebaseAdminAccessToken {
  @override
  final String data;

  FirebaseAdminAccessTokenRest({this.data});

  @override
  int get expiresIn => null;
}

class FirebaseAdminCredentialRestImpl implements FirebaseAdminCredentialRest {
  ServiceAccountCredentials serviceAccountCredentials;
  final List<String> scopes;
  AuthClient authClient;
  AppOptionsRest appOptions;
  String projectId;
  FirebaseAdminCredentialRestImpl.fromServiceAccountJson(
      String serviceAccountJson,
      {List<String> scopes})
      : scopes = scopes ?? firebaseBaseScopes {
    var jsonData = jsonDecode(serviceAccountJson);
    projectId = jsonData['project_id']?.toString();
    serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonData);
  }

  Future<FirebaseAdminAccessToken> _accessToken;
  @override
  Future<FirebaseAdminAccessToken> getAccessToken() =>
      _accessToken ??= () async {
        var client = Client();
        var accessCreds = await obtainAccessCredentialsViaServiceAccount(
            serviceAccountCredentials, scopes, client);
        var accessToken = accessCreds.accessToken;
        authClient = authenticatedClient(client, accessCreds);
        appOptions = AppOptionsRest(authClient: authClient)
          ..projectId = projectId;
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

/// Rest credentials implementation
abstract class FirebaseAdminCredentialRest implements FirebaseAdminCredential {
  factory FirebaseAdminCredentialRest.fromServiceAccountJson(
      String serviceAccountJson,
      {List<String> scopes}) {
    return FirebaseAdminCredentialRestImpl.fromServiceAccountJson(
        serviceAccountJson,
        scopes: scopes);
  }
}

class FirebaseAdminCredentialServiceRest
    implements FirebaseAdminCredentialService {
  final FirebaseRestImpl firebaseRest;
  FirebaseAdminCredentialServiceRest(this.firebaseRest);

  FirebaseAdminCredentialRest _applicationDefault;
  @override
  FirebaseAdminCredential applicationDefault() => _applicationDefault;

  // Must be called on setup
  @override
  void setApplicationDefault(FirebaseAdminCredential credential) {
    _applicationDefault = credential as FirebaseAdminCredentialRest;
  }
}
