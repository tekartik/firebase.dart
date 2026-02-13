import 'app_options.dart';
import 'firebase.dart';
import 'firebase_app_product.dart';
import 'firebase_mixin.dart';
import 'firebase_product_service.dart';

/// The default name for a [FirebaseApp], used when no name is provided.
const firebaseAppNameDefault = '[DEFAULT]';

/// A typedef for [FirebaseApp] for backward compatibility.
///
/// This will be deprecated in the future. Use [FirebaseApp] instead.
typedef App = FirebaseApp;

/// A Firebase App holds the common configuration for a given Firebase project
/// and is the entry point for all Firebase services.
abstract class FirebaseApp {
  /// The name of this app.
  String get name;

  /// The options that this app was initialized with.
  FirebaseAppOptions get options;

  /// Deletes this app and frees up system resources, including closing any
  /// services associated with it.
  ///
  /// Once deleted, any plugin functionality using this app instance will throw
  /// an error.
  ///
  /// Deleting the default app is not possible and will throw an exception.
  Future<void> delete();

  /// Adds a [FirebaseProductService] to this app and calls its `init` method.
  ///
  /// This is typically used by the service implementation itself to register
  /// for lifecycle events (e.g., being closed when the app is deleted).
  ///
  /// Upon [delete], the service's `close` method will be called.
  Future<void> addService(FirebaseProductService service);

  /// Retrieves a product (service instance) that has been initialized for this app.
  ///
  /// Returns `null` if the product of type [T] is not found.
  T? getProduct<T extends FirebaseAppProduct>();

  /// The [Firebase] instance that this app belongs to.
  Firebase get firebase;

  /// Returns `true` if the app is running in a local environment (e.g.,
  /// `FirebaseLocal`), not using real backend services (REST, Node.js, Flutter).
  bool get isLocal;

  /// Returns `true` if the app has been initialized with admin credentials.
  bool get hasAdminCredentials;

  /// The most recently initialized [FirebaseApp] instance.
  ///
  /// This is often the default app, but in a multi-app environment, it could be
  /// the last app that was initialized.
  static FirebaseApp get instance =>
      FirebaseMixin.latestFirebaseInstanceOrNull!;
}

/// Useful extensions on the [FirebaseApp] class.
extension TekartikFirebaseAppExt on FirebaseApp {
  /// The project ID from the app's options.
  ///
  /// This is a convenience getter that assumes the project ID is never null,
  /// as it is a fundamental part of a valid Firebase configuration.
  String get projectId => options.projectId!;
}
