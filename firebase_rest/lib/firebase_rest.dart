import 'package:googleapis_auth/auth.dart';
import 'package:http/http.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase_rest/src/firebase_rest.dart';

export 'package:tekartik_firebase_rest/src/firebase_rest.dart'
    show AppOptionsRest, FirebaseAdminCredentialRest;

export 'src/app_options_access_token.dart' show getAppOptionsFromAccessToken;
export 'src/scopes.dart'
    show
        firebaseBaseScopes,
        firebaseGoogleApisCloudPlatformScope,
        firebaseGoogleApisUserEmailScope;

/// Rest extension (if any)
abstract class FirebaseRest implements FirebaseAdmin {}

/// Rest firebase api
FirebaseRest get firebaseRest => impl;

/// Rest app extension (if any)
abstract class AppRest implements App {
  // Compat
  @deprecated
  AuthClient get authClient;

  Client get client;
}
