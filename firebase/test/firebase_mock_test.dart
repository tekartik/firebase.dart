import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart';
import 'package:tekartik_firebase/src/firebase_mock.dart';

import 'package:test/test.dart';

// ignore: unused_element
class _FirebaseAppProductTest with FirebaseAppProductMixin {
  @override
  final FirebaseApp app;

  _FirebaseAppProductTest(this.app);
}

// ignore: unused_element
class _FirebaseProductServiceTest with FirebaseProductServiceMixin {}

void main() {
  group('firebase', () {
    test('service', () async {
      var firebase = FirebaseMock() as Firebase;
      var app = firebase.initializeApp();
      expect(Firebase.apps, contains(app));
      expect(app.projectId, 'mock');
      expect(app.hasAdminCredentials, isFalse);
      expect(FirebaseApp.instance, app);

      var service = FirebaseProductServiceMock();
      await app.addService(service);
      expect(service.initCount, 1);
      await app.delete();
      expect(service.initCount, 0);
      expect(Firebase.apps, isNot(contains(app)));
    });
    test('product service', () {
      var firebase = FirebaseMock() as Firebase;
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
      var firebase = FirebaseMock() as Firebase;
      var app = firebase.initializeApp() as FirebaseAppMock;
      var service = FirebaseProductServiceMock();
      expect(app.getProduct<FirebaseAppProductMockBase>(), isNull);
      var productMock = service.product(app);
      expect(app.getProduct<FirebaseAppProductMockBase>(), productMock);
      await app.delete();
    });
    test('dispose', () async {
      var firebase = FirebaseMock() as Firebase;
      var app = firebase.initializeApp();
      var service = FirebaseProductServiceMock();

      var productMock = service.product(app);
      expect(productMock.disposed, isFalse);
      await app.delete();
      expect(productMock.disposed, isTrue);
    });

    test('admin', () async {
      var firebase = FirebaseAdminMock() as FirebaseAdmin;
      var app = firebase.initializeApp();
      expect(app.hasAdminCredentials, isTrue);
    });
  });
}
