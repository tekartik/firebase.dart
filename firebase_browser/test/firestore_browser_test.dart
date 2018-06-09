@TestOn('browser')
library tekartik_firebase_server_io.firestore_browser_test;

import 'package:tekartik_firebase_browser/src/firebase_browser.dart';
import 'package:tekartik_firebase_test/firestore_test.dart';
import 'package:test/test.dart';

import 'test_setup.dart';

void main() async {
  var options = await setup();
  if (options == null) {
    return;
  }
  run(firebaseBrowser, options: options);
}
