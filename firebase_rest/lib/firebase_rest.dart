import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase_rest/src/firebase_rest.dart';

export 'package:tekartik_firebase_rest/src/firebase_rest.dart'
    show
        AppOptionsRest,
        FirebaseAdminCredentialRest,
        FirebaseAdminRestExtension;

export 'src/app_options_access_token.dart' show getAppOptionsFromAccessToken;
export 'src/scopes.dart'
    show
        firebaseBaseScopes,
        firebaseGoogleApisCloudPlatformScope,
        firebaseGoogleApisUserEmailScope;

/// Rest extension (if any)
abstract class FirebaseRest implements Firebase {}

/// Rest extension (if any)
abstract class FirebaseAdminRest implements FirebaseRest, FirebaseAdmin {}

/// Rest firebase api
FirebaseAdminRest get firebaseRest => impl;

/// Rest app extension (if any)
abstract class AppRest implements App {
  // Compat
  @Deprecated('Use client')
  AuthClient? get authClient;

  // @Deprecated('Use client')
  Client? get client;

  @Deprecated('Only implementation should call that')
  set client(Client? client);
}
