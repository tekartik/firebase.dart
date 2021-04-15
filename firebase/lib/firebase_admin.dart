import 'firebase.dart';

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
  /// Default accessible in node in firebase functions or with
  /// GOOGLE_APPLICATION_CREDENTIALS env variable.
  FirebaseAdminCredential? applicationDefault();

  /// To set on setup if needed (needed for rest).
  void setApplicationDefault(FirebaseAdminCredential? credential);
}
