import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase/src/firebase_mock.dart';

import 'package:test/test.dart';

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

    test('options', () async {
      var firebase = FirebaseMock() as Firebase;
      var options = AppOptions(projectId: 'p1');
      var app = firebase.initializeApp(options: options, name: 'options');
      expect(app.projectId, 'p1');
      expect(app.options, options);
      expect(options.projectId, 'p1');
      await app.delete();
    });

    test('admin name already initialized', () async {
      var firebase = FirebaseAdminMock() as FirebaseAdmin;
      var app = firebase.initializeApp(name: 'dup');
      expect(
        () => firebase.initializeApp(name: 'dup'),
        throwsA(isA<StateError>()),
      );
      expect(firebase.app(name: 'dup'), app);
      await app.delete();
    });
  });
}
