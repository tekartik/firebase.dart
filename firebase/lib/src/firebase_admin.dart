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

/// Provides access to the application-default admin credential.
abstract class FirebaseAdminCredentialService
    implements FirebaseCredentialService {
  /// The application-default credential, if one is available.
  ///
  /// On Node.js and in Cloud Functions this is usually populated
  /// automatically, either from the runtime environment or from the
  /// `GOOGLE_APPLICATION_CREDENTIALS` environment variable. Other platforms
  /// (e.g. REST) require [setApplicationDefault] to be called explicitly.
  ///
  /// Returns `null` if no application-default credential is available.
  FirebaseAdminCredential? applicationDefault();

  /// Sets the application-default [credential] later returned by
  /// [applicationDefault].
  ///
  /// [credential] is the credential to use; pass `null` to clear a
  /// previously set credential. Required on platforms (e.g. REST) that
  /// cannot resolve an application-default credential automatically.
  void setApplicationDefault(FirebaseAdminCredential? credential);
}

/// Marker base interface for credential services.
///
/// See [FirebaseAdminCredentialService] for the admin implementation.
abstract class FirebaseCredentialService {}
