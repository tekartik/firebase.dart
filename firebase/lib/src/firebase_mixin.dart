/// Internal implementation mixins.
library;

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'firebase_admin.dart';

/// Firebase app list, for all implementation
final firebaseApps = <FirebaseApp>{};

/// Firebase mixin.
mixin FirebaseWithAppsMixin implements Firebase {
  final _apps = <String, FirebaseApp?>{};

  /// Add the app
  T addApp<T extends FirebaseApp>(T app) {
    _apps[app.name] = FirebaseMixin.addApp(app);
    return app;
  }

  /// Check if the app name is already used
  void checkAppNameUninitialized(String name) {
    if (_apps.containsKey(name)) {
      throw StateError('Firebase app named "$name" already exists');
    }
  }

  /// Uninitialize the app
  void uninitializeApp(FirebaseApp app) {
    FirebaseMixin.removeApp(app);
    _apps.remove(app.name);
  }

  @override
  App app({String? name}) {
    return FirebaseMixin.addApp(_apps[name ?? firebaseAppNameDefault]!);
  }
}

/// Firebase mixin.
/// @internal
mixin FirebaseMixin implements Firebase {
  /// Global to all firebase implementation
  static T addApp<T extends FirebaseApp>(T app) {
    firebaseApps.add(app);
    latestFirebaseInstanceOrNull = app;
    return app;
  }

  /// Global to all firebase implementation
  static void removeApp(FirebaseApp app) {
    firebaseApps.remove(app);
    if (latestFirebaseInstanceOrNull == app) {
      latestFirebaseInstanceOrNull = firebaseApps.lastOrNull;
    }
  }

  @override
  Future<App> initializeAppAsync({AppOptions? options, String? name}) async =>
      initializeApp(options: options, name: name);
  @override
  Future<App> appAsync({String? name}) async => app(name: name);

  /// The latest initialized firebase app instance.
  /// Prefer using addApp/removeApp
  static FirebaseApp? latestFirebaseInstanceOrNull;

  @override
  bool get isLocal => false;
}

/// Admin mixin.
/// @internal
mixin FirebaseAdminMixin implements FirebaseAdmin {
  @override
  FirebaseAdminCredentialService get credential => throw UnimplementedError();
}

/// Firebase app mixin.
/// @internal
mixin FirebaseAppMixin implements FirebaseApp {
  final _servicesLock = Lock();
  final _services = <FirebaseProductService>{};
  final _product = <Type, FirebaseAppProduct>{};

  /// Add a product to the app for later retrieval.
  void addProduct(FirebaseAppProduct product) {
    _product[product.type] = product;
  }

  /// Get the product for the type
  @override
  T? getProduct<T extends FirebaseAppProduct>() {
    var product = _product[T];
    return product as T?;
  }

  /// Close all added service.
  Future<void> closeServices() {
    return _servicesLock.synchronized(() async {
      for (var service in _services) {
        await service.close(this);
      }
      _services.clear();
    });
  }

  /// Add a service and calls its init method.
  ///
  /// Upon delete, close will be called.
  @override
  Future addService(FirebaseProductService service) {
    return _servicesLock.synchronized(() async {
      await service.init(this);
      _services.add(service);
    });
  }

  /// Get firebase, new as of 2024-07-31
  @override
  Firebase get firebase => throw UnimplementedError('FirebaseApp.firebase');

  @override
  bool get isLocal => firebase.isLocal;

  @override
  bool get hasAdminCredentials => false;

  @override
  String toString() {
    return 'FirebaseApp(name: $name, options: $options, isLocal: $isLocal)';
  }
}

/// Helper for any app product (firestore, storage...).
/// @internal
mixin FirebaseAppProductMixin<T> implements FirebaseAppProduct<T> {
  var _disposed = false;

  @override
  Type get type => T;

  /// True if disposed
  bool get disposed => _disposed;

  @mustCallSuper
  @override
  void dispose() {
    _disposed = true;
  }
}

/// Compat Helper for any app service (firestore, storage...).
/// @internal
mixin FirebaseProductServiceMixin<T> implements FirebaseProductService {
  /// Most implementation need a single instance, keep it in memory!
  final _instances = <App, T>{};

  /// Get the instance for the app, create it if not found
  I getInstance<I extends T>(App app, T Function() createIfNotFound) {
    var instance = _instances[app];
    if (instance == null) {
      app.addService(this);
      var newInstance = instance = createIfNotFound();
      _instances[app] = newInstance;

      /// Add the product to the app
      if (app is FirebaseAppMixin && newInstance is FirebaseAppProduct) {
        app.addProduct(newInstance);
      }
    }
    return instance as I;
  }

  @mustCallSuper
  @override
  Future<void> close(App app) async {
    var instance = _instances.remove(app);
    if (instance is FirebaseAppProduct) {
      instance.dispose();
    }
  }

  @mustCallSuper
  @override
  Future<void> init(App app) async {}
}

/// Test extension.
/// @internal
extension FirebaseProductServiceMixinExt<T> on FirebaseProductService {
  /// Get the existing instance for the app, if any
  @visibleForTesting
  T? getExistingInstance(App app) =>
      (this as FirebaseProductServiceMixin<T>)._instances[app];
}
