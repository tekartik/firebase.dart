// This file is use by the implementation, should be considerd like a public api
// although not exposed.
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_firebase/firebase.dart';

mixin FirebaseMixin implements Firebase {
  @override
  Future<App> initializeAppAsync({AppOptions? options, String? name}) async =>
      initializeApp(options: options, name: name);
  @override
  Future<App> appAsync({String? name}) async => app(name: name);
}
mixin FirebaseAppMixin implements App {
  final _servicesLock = Lock();
  final _services = <FirebaseAppService>[];

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
  Future addService(FirebaseAppService service) {
    return _servicesLock.synchronized(() async {
      await service.init(this);
      _services.add(service);
    });
  }
}
