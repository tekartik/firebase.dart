import 'dart:async';

import 'src/app_options.dart';
export 'package:tekartik_firebase/src/app_options.dart'
    show AppOptions, FirebaseAppOptions, FirebaseAppOptionsMixin;

export 'package:tekartik_firebase/src/firebase.dart'
    show firebaseAppNameDefault, FirebaseAppProductService, FirebaseAppProduct;
export 'package:tekartik_firebase/src/firebase_mixin.dart'
    show FirebaseProductServiceMixin;

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

  /// Dispose the app.
  ///
  /// Close all added service.
  Future<void> delete();

  /// Add a service and calls its init method.
  ///
  /// Upon delete, close will be called
  Future<void> addService(FirebaseProductService service);

  /// Get firebase
  Firebase get firebase;

  /// True if local (nor node, nor rest, nor flutter)
  bool get isLocal;
}

/// Attached firebase service.
///
/// Init is called
abstract class FirebaseProductService {
  /// Called when [App.addService] is called
  Future<void> init(App app);

  /// Called when [App.delete] is called
  Future<void> close(App app);
}
