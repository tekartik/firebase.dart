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

class FirebaseAppServiceMock implements FirebaseAppService {
  int initCount = 0;

  @override
  Future close(App app) async {
    initCount--;
  }

  @override
  Future init(App app) async {
    initCount++;
  }
}

// ignore: unreachable_from_main
class FirebaseAppOptionsMock with FirebaseAppOptionsMixin {}

class FirebaseProductMock {}

class FirebaseProductServiceMock
    with FirebaseProductServiceMixin<FirebaseProductMock> {
  FirebaseProductMock product(App app) =>
      getInstance(app, FirebaseProductMock.new);
}

void main() {
  group('firebase', () {
    test('service', () async {
      var firebase = FirebaseMock();
      var app = firebase.initializeApp();
      var service = FirebaseAppServiceMock();
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
  });
}
