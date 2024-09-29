@TestOn('browser')
library;

import 'package:tekartik_firebase_browser/firebase_browser.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_setup.dart';

void main() async {
  var options = await setup();
  // ignore: deprecated_member_use_from_same_package
  final firebase = firebaseBrowser;

  group('browser', () {
    test('appOptions', () {
      expect(options, isNotNull, reason: 'All tests are skipped');
    }, skip: options == null);
    if (options == null) {
      return;
    }
    runFirebaseTests(firebase, options: options);
  });
}
