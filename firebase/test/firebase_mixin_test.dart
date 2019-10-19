library tekartik_firebase.firebase_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart';
import 'package:test/test.dart';

class FirebaseMock with FirebaseMixin {
  @override
  App initializeApp({AppOptions options, String name}) {
    return FirebaseAppMock(options: options, name: name);
  }
}

class FirebaseAppMock with FirebaseAppMixin {
  FirebaseAppMock({this.name, this.options});

  @override
  Future<void> delete() async {
    await closeServices();
  }

  @override
  final String name;

  @override
  final AppOptions options;
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
  });
}
