/// The shared Firebase tests: [runFirebaseTests] on a new app of an
/// implementation.
library;

import 'package:tekartik_firebase_test/firebase_app_test.dart';
import 'package:test/test.dart';

import 'firebase_product_test.dart';
export 'package:tekartik_firebase/firebase.dart';

@Deprecated('Preferred runFirebaseTests')
void runApp(FirebaseAsync firebaseAsync, {AppOptions? options, String? name}) =>
    runFirebaseTests(firebaseAsync, options: options, name: name);

/// Declares the tests on a new app of [firebaseAsync] (named [name], with
/// [options]), deleted in `tearDownAll`. Call it in its own `group()`.
void runFirebaseTests(
  FirebaseAsync firebaseAsync, {
  AppOptions? options,
  String? name,
}) {
  late FirebaseApp app;
  setUpAll(() async {
    app = await firebaseAsync.initializeAppAsync(options: options, name: name);
    expect(Firebase.apps, contains(app));
  });
  tearDownAll(() async {
    await app.delete();
    expect(Firebase.apps, isNot(contains(app)));
  });

  runFirebaseAppTests(firebaseAsync, () => app);
  runFirebaseAppProductTests(firebaseAsync, () => app);
  group('Firebase', () {
    test('apps', () {
      expect(Firebase.apps, contains(app));
    });
    test('default app name', () async {
      expect(app.name, name ?? '[DEFAULT]');
      //expect(FirebaseApp.instance, app);
      expect((await firebaseAsync.appAsync(name: app.name)).name, app.name);
      expect(
        (await firebaseAsync.appAsync(name: app.name)).options.projectId,
        app.options.projectId,
      );
    });

    test('app returns the same app', () async {
      // The same instance, with its products and services, not a new one.
      expect(await firebaseAsync.appAsync(name: app.name), same(app));
      if (firebaseAsync is Firebase) {
        expect(firebaseAsync.app(name: app.name), same(app));
      }
    });

    test('reinit', () async {
      expect(Firebase.apps, contains(app));
      await app.delete();
      expect(Firebase.apps, isNot(contains(app)));
      app = await firebaseAsync.initializeAppAsync(
        options: options,
        name: name,
      );
    });
  });
}
