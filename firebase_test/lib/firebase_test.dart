library tekartik_tekartik_firebase_sembast.admin_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:test/test.dart';

/*
void run(FirebaseAsync firebase, {AppOptions options}) {
  App app = firebase.initializeApp(options: options);

  tearDownAll(() {
    return app.delete();
  });

  runApp(firebase, app);
}
*/
void runApp(FirebaseAsync firebaseAsync, {AppOptions options}) {
  App app;
  setUpAll(() async {
    app = await firebaseAsync.initializeAppAsync(options: options);
  });
  tearDownAll(() async {
    return app.delete();
  });

  group('Firebase', () {
    test('default app name', () {
      expect(app.name, '[DEFAULT]');
      /*
      expect(app.options.projectId, isNotEmpty);
      devPrint("projectId: ${app.options.projectId}");
      devPrint("projectId: ${app.options.storageBucket}");
      */
    });

    /*
    test('app name', () async {
      App app = firebase.initializeApp(name: "test");
      // expect(app.name, 'test');
      await app.delete();
    });

    test('app options', () async {
      App app = firebase.initializeApp(
          options: new AppOptions(projectId: "testProjectId"), name: "test");
      expect(app.name, 'test');
      expect(app.options.projectId, 'testProjectId');
      await app.delete();
    });
    */
  });
}
