import 'package:tekartik_firebase/firebase.dart';

/// Interface for a firebase service (auth, firestore, storage...)
///
/// A service is a singleton shared between apps.
abstract class FirebaseAppProductService {}

/// Interface for a firebase app service (auth, firestore, storage...)
///
/// An app service is created per app.
abstract class FirebaseAppProduct<T> {
  /// The app
  FirebaseApp get app;

  /// The type of the product
  Type get type;

  /// Close the service
  void dispose();
}
