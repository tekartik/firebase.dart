import 'package:tekartik_firebase/firebase.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mock.dart';
import 'package:test/test.dart';

// The mocks of tekartik_firebase, kept exported from here.
// ignore: implementation_imports
export 'package:tekartik_firebase/src/firebase_mock.dart'
    show
        FirebaseProductServiceMock,
        FirebaseAppOptionsMock,
        FirebaseAppProductMockBase,
        FirebaseAppProductMock;

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
      await service.close(app);
      expect(service.initCount, 0);
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
      await service.close(app);
      expect(productMock.disposed, isTrue);
    });
  });
}
