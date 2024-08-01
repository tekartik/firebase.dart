import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart';
import 'package:test/test.dart';

String get _defaultAppName => firebaseAppNameDefault;
String get _defaultProjectId => 'mock';

class FirebaseMock with FirebaseMixin {
  final _apps = <String, App?>{};
  @override
  App initializeApp({AppOptions? options, String? name}) {
    name ??= _defaultAppName;
    var app = FirebaseAppMock(firebaseMock: this, options: options, name: name);
    _apps[name] = app;
    return app;
  }

  @override
  App app({String? name}) {
    return _apps[name ?? _defaultAppName]!;
  }
}

class FirebaseAppMock with FirebaseAppMixin {
  final FirebaseMock firebaseMock;
  FirebaseAppMock(
      {required this.firebaseMock, String? name, AppOptions? options}) {
    this.options = options ?? AppOptions()
      ..projectId = _defaultProjectId;
    this.name = name ?? _defaultAppName;
  }

  @override
  Firebase get firebase => firebaseMock;
  @override
  Future<void> delete() async {
    await closeServices();
  }

  @override
  late final String name;

  @override
  late final AppOptions options;
}

// ignore: unused_element
class _FirebaseAppProductTest with FirebaseAppProductMixin {}

// ignore: unused_element
class _FirebaseProductServiceTest with FirebaseProductServiceMixin {}

class FirebaseProductServiceMock
    with FirebaseProductServiceMixin<FirebaseAppProductMockBase> {
  int initCount = 0;

  FirebaseAppProductMock product(App app) =>
      getInstance<FirebaseAppProductMock>(app, FirebaseAppProductMock.new);

  @override
  Future<void> close(App app) async {
    initCount--;
    await super.close(app);
  }

  @override
  Future<void> init(App app) async {
    initCount++;
    await super.init(app);
  }
}

// ignore: unreachable_from_main
class FirebaseAppOptionsMock with FirebaseAppOptionsMixin {}

/// test base definition
abstract class FirebaseAppProductMockBase {}

class FirebaseAppProductMock
    with FirebaseAppProductMixin<FirebaseAppProductMockBase>
    implements FirebaseAppProductMockBase {}

void main() {
  group('firebase', () {
    test('service', () async {
      var firebase = FirebaseMock();
      var app = firebase.initializeApp();
      var service = FirebaseProductServiceMock();
      await app.addService(service);
      expect(service.initCount, 1);
      await app.delete();
      expect(service.initCount, 0);
    });
    test('product service', () {
      var firebase = FirebaseMock();
      var app1 = firebase.initializeApp(name: 'app1');
      var app2 = firebase.initializeApp(name: 'app2');
      expect(app1, isNot(app2));
      var service = FirebaseProductServiceMock();
      var product1 = service.product(app1);
      var product2 = service.product(app2);
      var product1bis = service.product(app1);
      expect(product1, isNot(product2));
      expect(product1, product1bis);
    });
    test('product', () async {
      var firebase = FirebaseMock();
      var app = firebase.initializeApp() as FirebaseAppMock;
      var service = FirebaseProductServiceMock();
      expect(app.getProduct<FirebaseAppProductMockBase>(), isNull);
      var productMock = service.product(app);
      expect(app.getProduct<FirebaseAppProductMockBase>(), productMock);
      await app.delete();
    });
    test('dispose', () async {
      var firebase = FirebaseMock();
      var app = firebase.initializeApp();
      var service = FirebaseProductServiceMock();

      var productMock = service.product(app);
      expect(productMock.disposed, isFalse);
      await app.delete();
      expect(productMock.disposed, isTrue);
    });
  });
}
