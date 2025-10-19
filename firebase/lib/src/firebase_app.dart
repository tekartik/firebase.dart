import 'app_options.dart';
import 'firebase.dart';
import 'firebase_mixin.dart';
import 'firebase_product_service.dart';

/// The default [FirebaseApp] name.
const firebaseAppNameDefault = '[DEFAULT]';

/// This is the new type, App will be deprecated in the future
typedef App = FirebaseApp;

/// Firebase app.
abstract class FirebaseApp {
  /// The app name
  String get name;

  /// The app options
  FirebaseAppOptions get options;

  /// Deletes this app and frees up system resources.
  ///
  /// Once deleted, any plugin functionality using this app instance will throw
  /// an error.
  ///
  /// Deleting the default app is not possible and throws an exception.
  Future<void> delete();

  /// Add a service and calls its init method.
  ///
  /// Upon delete, close will be called
  Future<void> addService(FirebaseProductService service);

  /// Get firebase
  Firebase get firebase;

  /// True if local (nor node, nor rest, nor flutter)
  bool get isLocal;

  /// True if it has admin credentials
  bool get hasAdminCredentials;

  /// The latest initialized firebase app instance.
  static FirebaseApp get instance =>
      FirebaseMixin.latestFirebaseInstanceOrNull!;
}

/// Firebase app extensions
extension TekartikFirebaseAppExt on FirebaseApp {
  /// Project id should never be null!
  String get projectId => options.projectId!;
}
