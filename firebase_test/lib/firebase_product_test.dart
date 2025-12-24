import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';

import 'package:test/test.dart';

void runFirebaseAppProductTests(
  FirebaseAsync firebaseAsync,
  FirebaseApp Function() getFirebaseApp,
) {
  group('app_product', () {
    test('service', () async {
      var app = getFirebaseApp();

      var service = FirebaseProductServiceMock();
      await app.addService(service);
      expect(service.initCount, 1);
    });

    test('product', () async {
      var app = getFirebaseApp();
      var service = FirebaseProductServiceMock();
      expect(app.getProduct<FirebaseAppProductMockBase>(), isNull);
      var productMock = service.product(app);
      expect(app.getProduct<FirebaseAppProductMockBase>(), productMock);
    });
    test('dispose', () async {
      var app = getFirebaseApp();
      var service = FirebaseProductServiceMock();

      var productMock = service.product(app);
      expect(productMock.disposed, isFalse);
    });
  });
}

// ignore: unused_element
class _FirebaseAppProductTest with FirebaseAppProductMixin {
  @override
  final FirebaseApp app;

  _FirebaseAppProductTest(this.app);
}

// ignore: unused_element
class _FirebaseProductServiceTest with FirebaseProductServiceMixin {}

class FirebaseProductServiceMock
    with FirebaseProductServiceMixin<FirebaseAppProductMockBase> {
  int initCount = 0;

  FirebaseAppProductMock product(App app) =>
      getInstance<FirebaseAppProductMock>(
        app,
        () => FirebaseAppProductMock(app),
      );

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
abstract class FirebaseAppProductMockBase
    implements FirebaseAppProduct<FirebaseAppProductMockBase> {}

class FirebaseAppProductMock
    with FirebaseAppProductMixin<FirebaseAppProductMockBase>
    implements FirebaseAppProductMockBase {
  @override
  final FirebaseApp app;

  FirebaseAppProductMock(this.app);
}
