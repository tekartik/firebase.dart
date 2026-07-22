/// Mixins used by concrete [Firebase] implementations (mock, REST, Node.js,
/// Flutter, ...) to share common bookkeeping logic.
///
/// Exposed for package implementers; most apps should use [Firebase] and
/// [FirebaseApp] directly instead of these mixins.
library;

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'firebase_admin.dart';

/// All [FirebaseApp] instances currently registered, across every [Firebase]
/// implementation in the process.
///
/// Populated by [FirebaseMixin.addApp] and [FirebaseMixin.removeApp].
final firebaseApps = <FirebaseApp>{};

/// Mixin implementing [Firebase] app-registry bookkeeping for
/// implementations that store their own named app instances.
mixin FirebaseWithAppsMixin implements Firebase {
  final _apps = <String, FirebaseApp?>{};

  /// Registers [app] with this [Firebase] instance, under [FirebaseApp.name].
  ///
  /// Also registers [app] globally via [FirebaseMixin.addApp].
  ///
  /// Returns [app] unchanged, for convenient chaining.
  T addApp<T extends FirebaseApp>(T app) {
    _apps[app.name] = FirebaseMixin.addApp(app);
    return app;
  }

  /// Throws a [StateError] if an app named [name] has already been
  /// registered with this [Firebase] instance.
  void checkAppNameUninitialized(String name) {
    if (_apps.containsKey(name)) {
      throw StateError('Firebase app named "$name" already exists');
    }
  }

  /// Removes [app] from this [Firebase] instance and from the global app
  /// registry (see [FirebaseMixin.removeApp]).
  void uninitializeApp(FirebaseApp app) {
    FirebaseMixin.removeApp(app);
    _apps.remove(app.name);
  }

  /// See [Firebase.app].
  ///
  /// Throws if no app named [name] (or the default app, if [name] is
  /// omitted) has been registered via [addApp].
  @override
  App app({String? name}) {
    return FirebaseMixin.addApp(_apps[name ?? firebaseAppNameDefault]!);
  }
}

/// Mixin providing the process-global app registry ([firebaseApps]) shared
/// by every [Firebase] implementation, plus default implementations of the
/// asynchronous [Firebase] members in terms of their synchronous
/// counterparts.
mixin FirebaseMixin implements Firebase {
  /// Registers [app] in the process-global [firebaseApps] registry and marks
  /// it as [latestFirebaseInstanceOrNull].
  ///
  /// Returns [app] unchanged, for convenient chaining.
  static T addApp<T extends FirebaseApp>(T app) {
    firebaseApps.add(app);
    latestFirebaseInstanceOrNull = app;
    return app;
  }

  /// Removes [app] from the process-global [firebaseApps] registry.
  ///
  /// If [app] was [latestFirebaseInstanceOrNull], that field is updated to
  /// the most recently registered remaining app, or `null` if none remain.
  static void removeApp(FirebaseApp app) {
    firebaseApps.remove(app);
    if (latestFirebaseInstanceOrNull == app) {
      latestFirebaseInstanceOrNull = firebaseApps.lastOrNull;
    }
  }

  /// See [FirebaseAsync.initializeAppAsync]. Implemented by delegating to
  /// [Firebase.initializeApp].
  @override
  Future<App> initializeAppAsync({AppOptions? options, String? name}) async =>
      initializeApp(options: options, name: name);

  /// See [FirebaseAsync.appAsync]. Implemented by delegating to
  /// [Firebase.app].
  @override
  Future<App> appAsync({String? name}) async => app(name: name);

  /// The most recently registered [FirebaseApp], or `null` if none is
  /// registered.
  ///
  /// Prefer using [addApp]/[removeApp] to keep this field consistent rather
  /// than setting it directly.
  static FirebaseApp? latestFirebaseInstanceOrNull;

  /// `false`: implementations using this mixin are not local by default.
  @override
  bool get isLocal => false;
}

/// Mixin providing a default [FirebaseAdmin.credential] that throws
/// [UnimplementedError] until overridden by a concrete implementation.
mixin FirebaseAdminMixin implements FirebaseAdmin {
  /// See [FirebaseAdmin.credential]. Throws [UnimplementedError] unless
  /// overridden.
  @override
  FirebaseAdminCredentialService get credential => throw UnimplementedError();
}

/// Mixin providing the common bookkeeping ([FirebaseProductService]
/// lifecycle, [FirebaseAppProduct] lookup) shared by [FirebaseApp]
/// implementations.
mixin FirebaseAppMixin implements FirebaseApp {
  final _servicesLock = Lock();
  final _services = <FirebaseProductService>{};
  final _product = <Type, FirebaseAppProduct>{};

  /// Registers [product] so it can later be retrieved with [getProduct].
  ///
  /// [product] is indexed by its [FirebaseAppProduct.type], replacing any
  /// previously registered product of the same type.
  void addProduct(FirebaseAppProduct product) {
    _product[product.type] = product;
  }

  /// See [FirebaseApp.getProduct].
  @override
  T? getProduct<T extends FirebaseAppProduct>() {
    var product = _product[T];
    return product as T?;
  }

  /// Closes every [FirebaseProductService] previously registered via
  /// [addService], in an undefined order, then clears the internal registry.
  ///
  /// Returns a [Future] that completes once all services have been closed.
  Future<void> closeServices() {
    return _servicesLock.synchronized(() async {
      for (var service in _services) {
        await service.close(this);
      }
      _services.clear();
    });
  }

  /// See [FirebaseApp.addService].
  @override
  Future addService(FirebaseProductService service) {
    return _servicesLock.synchronized(() async {
      await service.init(this);
      _services.add(service);
    });
  }

  /// Base [FirebaseApp.delete] implementation: closes every registered
  /// service (see [closeServices]) then unregisters this app from its
  /// owning [firebase] instance.
  ///
  /// Can be overridden by implementations that need extra cleanup; the
  /// override should call this base implementation.
  @override
  Future delete() async {
    await closeServices();
    Firebase? firebase = this.firebase;
    if (firebase is FirebaseWithAppsMixin) {
      firebase.uninitializeApp(this);
    } else {
      FirebaseMixin.removeApp(this);
    }
  }

  /// See [FirebaseApp.firebase]. Throws [UnimplementedError] unless
  /// overridden.
  @override
  Firebase get firebase => throw UnimplementedError('FirebaseApp.firebase');

  /// See [FirebaseApp.isLocal]. Delegates to [firebase]'s [Firebase.isLocal].
  @override
  bool get isLocal => firebase.isLocal;

  /// `false`: implementations using this mixin have no admin credentials by
  /// default.
  @override
  bool get hasAdminCredentials => false;

  @override
  String toString() {
    return 'FirebaseApp(name: $name, options: $options, isLocal: $isLocal)';
  }
}

/// Helper mixin for a [FirebaseAppProduct] implementation (firestore,
/// storage...), tracking its [type] and [disposed] state.
mixin FirebaseAppProductMixin<T> implements FirebaseAppProduct<T> {
  var _disposed = false;

  /// See [FirebaseAppProduct.type]. Resolves to the mixin's type parameter
  /// [T].
  @override
  Type get type => T;

  /// `true` once [dispose] has been called.
  bool get disposed => _disposed;

  /// See [FirebaseAppProduct.dispose]. Marks [disposed] as `true`.
  ///
  /// Overrides must call `super.dispose()`.
  @mustCallSuper
  @override
  void dispose() {
    _disposed = true;
  }
}

/// Helper mixin for a [FirebaseAppProductService] implementation (firestore,
/// storage...) that needs at most one product instance per [App].
mixin FirebaseProductServiceMixin<T> implements FirebaseProductService {
  /// The instance of [T] created for each [App], keyed by that app.
  final _instances = <App, T>{};

  /// Returns the existing instance of [T] for [app], creating and caching
  /// one with [createIfNotFound] if none exists yet.
  ///
  /// [app] is the app the instance is scoped to; it is registered as a
  /// service of this [FirebaseProductServiceMixin] (via
  /// [FirebaseApp.addService]) the first time an instance is created for it.
  /// [createIfNotFound] is invoked at most once per [app], only when no
  /// cached instance exists yet.
  ///
  /// Returns the cached or newly created instance, cast to [I].
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

  /// See [FirebaseProductService.close]. Removes and disposes (if
  /// applicable) the instance cached for [app].
  ///
  /// Overrides must call `super.close(app)`.
  @mustCallSuper
  @override
  Future<void> close(App app) async {
    var instance = _instances.remove(app);
    if (instance is FirebaseAppProduct) {
      instance.dispose();
    }
  }

  /// See [FirebaseProductService.init]. No-op by default.
  ///
  /// Overrides must call `super.init(app)`.
  @mustCallSuper
  @override
  Future<void> init(App app) async {}
}

/// Testing helper for [FirebaseProductServiceMixin] implementations.
extension FirebaseProductServiceMixinExt<T> on FirebaseProductService {
  /// The instance of [T] already cached for [app] by
  /// [FirebaseProductServiceMixin.getInstance], if any.
  ///
  /// Returns `null` if no instance has been created for [app] yet.
  ///
  /// For use in tests only; requires `this` to be a
  /// [FirebaseProductServiceMixin].
  @visibleForTesting
  T? getExistingInstance(App app) =>
      (this as FirebaseProductServiceMixin<T>)._instances[app];
}
