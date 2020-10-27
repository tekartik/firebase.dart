import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_node/src/firebase_node.dart' as firebase_node;

/// Node firebase admin
FirebaseAdmin get firebaseNode => firebase_node.firebaseNode;

/// Only for node for now
abstract class FirebaseAdmin extends Firebase {
  FirebaseAdminCredentialService get credential;
}

/// Google OAuth2 access token object used to authenticate with Firebase services.
abstract class FirebaseAdminAccessToken {
  /// The actual Google OAuth2 access token.
  String get data;

  /// The number of seconds from when the token was issued that it expires.
  int get expiresIn;
}

/// Interface that provides Google OAuth2 access tokens used to authenticate with Firebase services.
abstract class FirebaseAdminCredential {
  /// Returns a Google OAuth2 access token object used to authenticate with Firebase services.
  Future<FirebaseAdminAccessToken> getAccessToken();
}

/// Credential service.
abstract class FirebaseAdminCredentialService {
  FirebaseAdminCredential applicationDefault();
}
