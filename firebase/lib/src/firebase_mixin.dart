// This file is use by the implementation, should be considerd like a public api
// although not exposed.
import 'package:tekartik_common_utils/common_utils_import.dart';
import '../firebase.dart';

/// Firebase mixin
mixin FirebaseMixin implements Firebase {
  @override
  Future<App> initializeAppAsync({AppOptions? options, String? name}) async =>
      initializeApp(options: options, name: name);
  @override
  Future<App> appAsync({String? name}) async => app(name: name);

  @override
  bool get isLocal => false;
}

/// Firebase app mixin
mixin FirebaseAppMixin implements App {
  final _servicesLock = Lock();
  final _services = <FirebaseProductService>{};
  final _product = <Type, FirebaseAppProduct>{};

  /// add the product to the app
  void addProduct(FirebaseAppProduct product) {
    _product[product.type] = product;
  }

  /// Get the product for the type
  T? getProduct<T>() {
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
}

/// Helper for any app produce (firestore, storage...)
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

/// Compat Helper for any app service (firestore, storage...)
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

/// Test extension
extension FirebaseProductServiceMixinExt<T> on FirebaseProductService {
  /// Get the existing instance for the app, if any
  @visibleForTesting
  T? getExistingInstance(App app) =>
      (this as FirebaseProductServiceMixin<T>)._instances[app];
}
