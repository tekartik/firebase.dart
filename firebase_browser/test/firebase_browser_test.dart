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
    }, skip: options == null);
    if (options == null) {
      return;
    }
    runApp(firebase, options: options);
  });
}
