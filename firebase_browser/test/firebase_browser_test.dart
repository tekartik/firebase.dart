@TestOn('browser')
library tekartik_firebase_server_io.firebase_admin_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_browser/firebase_browser.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_setup.dart';

void main() async {
  var options = await setup();
  Firebase firebase = firebaseBrowser;

  group('browser', () {
    test('appOptions', () {
      expect(options, isNotNull, reason: "All tests are skipped");
    });
    if (options == null) {
      return;
    }
    run(firebase, options: options);

    group('auth', () {
      App app = firebase.initializeApp(options: options, name: 'auth');

      tearDownAll(() {
        return app.delete();
      });

      test('signOut', () async {
        var auth = app.auth() as AuthBrowser;
        await auth.signOut();
        expect(await auth.onAuthStateChanged.take(1).toList(), [null]);
      });
    });
  });
}
