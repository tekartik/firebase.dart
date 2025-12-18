library;

import 'package:tekartik_firebase_test/firebase_app_test.dart';
import 'package:test/test.dart';
export 'package:tekartik_firebase/firebase.dart';
/*
void run(FirebaseAsync firebase, {AppOptions options}) {
  App app = firebase.initializeApp(options: options);

  tearDownAll(() {
    return app.delete();
  });

  runApp(firebase, app);
}
*/

@Deprecated('Preferred runFirebaseTests')
void runApp(FirebaseAsync firebaseAsync, {AppOptions? options, String? name}) =>
    runFirebaseTests(firebaseAsync, options: options, name: name);
void runFirebaseTests(
  FirebaseAsync firebaseAsync, {
  AppOptions? options,
  String? name,
}) {
  late FirebaseApp app;
  setUpAll(() async {
    app = await firebaseAsync.initializeAppAsync(options: options, name: name);
  });
  tearDownAll(() async {
    return app.delete();
  });

  runFirebaseAppTests(firebaseAsync, () => app);
  group('Firebase', () {
    test('default app name', () async {
      expect(app.name, name ?? '[DEFAULT]');
      //expect(FirebaseApp.instance, app);
      expect((await firebaseAsync.appAsync(name: app.name)).name, app.name);
      expect(
        (await firebaseAsync.appAsync(name: app.name)).options.projectId,
        app.options.projectId,
      );
    });

    test('reinit', () async {
      await app.delete();
      app = await firebaseAsync.initializeAppAsync(
        options: options,
        name: name,
      );
    });
  });
}
