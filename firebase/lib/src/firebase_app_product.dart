import 'package:tekartik_firebase/firebase.dart';

/// Interface for a Firebase service registry (auth, firestore, storage...).
///
/// A service is a singleton, instantiated once and shared between every
/// [FirebaseApp] that uses it.
abstract class FirebaseAppProductService {}

/// Interface for a Firebase service instance scoped to a single app (auth,
/// firestore, storage...).
///
/// One instance of [FirebaseAppProduct] is created per [FirebaseApp] that
/// uses the underlying [FirebaseAppProductService], and retrieved via
/// [FirebaseApp.getProduct].
abstract class FirebaseAppProduct<T> {
  /// The [FirebaseApp] this product instance belongs to.
  FirebaseApp get app;

  /// The runtime [Type] used to look up this product via
  /// [FirebaseApp.getProduct].
  Type get type;

  /// Releases any resources held by this product.
  ///
  /// Called automatically when the owning [app] is deleted or when the
  /// backing [FirebaseAppProductService] is closed.
  void dispose();
}
