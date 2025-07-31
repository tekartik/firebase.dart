import 'dart:async';

import 'firebase_mixin.dart';
import 'src/app_options.dart';
import 'src/firebase_product_service.dart';
export 'package:tekartik_firebase/src/app_options.dart'
    show AppOptions, FirebaseAppOptions, FirebaseAppOptionsMixin;

export 'package:tekartik_firebase/src/firebase.dart'
    show firebaseAppNameDefault;
export 'package:tekartik_firebase/src/firebase_app_product.dart'
    show FirebaseAppProductService, FirebaseAppProduct;
export 'package:tekartik_firebase/src/firebase_mixin.dart'
    show FirebaseProductServiceMixin;
export 'src/firebase_product_service.dart' show FirebaseProductService;

/// Async interface, needed for flutter.
abstract class FirebaseAsync {
  /// Initialize the app with the given options.
  Future<App> initializeAppAsync({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  Future<App> appAsync({String? name});
}

/// Firebase interface.
abstract class Firebase extends FirebaseAsync {
  /// Initialize the app with the given options.
  // @deprecated use async version
  App initializeApp({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  App app({String? name});

  /// True if firebase is local (i.e. FirebaseLocal, not rest, nor node, nor flutter
  bool get isLocal;
}

/// This is the new type, App will be deprecated in the future
typedef App = FirebaseApp;

/// Firebase app.
abstract class FirebaseApp {
  /// The app name
  String get name;

  /// The app options
  AppOptions get options;

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
