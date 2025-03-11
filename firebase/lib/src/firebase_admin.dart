import 'package:tekartik_firebase/firebase.dart';

/// Only for node and rest for now
abstract class FirebaseAdmin extends Firebase {
  /// Credential service.
  FirebaseAdminCredentialService get credential;
}

/// Google OAuth2 access token object used to authenticate with Firebase
/// services.
abstract class FirebaseAdminAccessToken extends FirebaseAccessToken {
  /// The actual Google OAuth2 access token.
  String get data;

  /// The number of seconds from when the token was issued that it expires.
  int get expiresIn;
}

/// Google OAuth2 access token object used to authenticate with Firebase
/// services.
abstract class FirebaseAccessToken {}

/// Interface that provides Google OAuth2 access tokens used to authenticate
/// with Firebase services.
abstract class FirebaseAdminCredential implements FirebaseAccessCredential {
  /// Returns a Google OAuth2 access token object used to authenticate with
  /// Firebase services.
  @override
  Future<FirebaseAdminAccessToken> getAccessToken();
}

/// Interface that provides Google OAuth2 access tokens used to authenticate
/// with Firebase services.
abstract class FirebaseAccessCredential {
  /// Returns a Google OAuth2 access token object used to authenticate with
  /// Firebase services.
  Future<FirebaseAccessToken> getAccessToken();
}

/// Credential service.
abstract class FirebaseAdminCredentialService
    implements FirebaseCredentialService {
  /// Default accessible in node in firebase functions or with
  /// GOOGLE_APPLICATION_CREDENTIALS env variable.
  FirebaseAdminCredential? applicationDefault();

  /// To set on setup if needed (needed for rest).
  void setApplicationDefault(FirebaseAdminCredential? credential);
}

/// Credential service.
abstract class FirebaseCredentialService {}
