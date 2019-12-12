import 'dart:html';

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_browser/firebase_browser.dart';
import 'package:tekartik_firebase_browser/src/interop.dart';

import 'example_common.dart';
import 'example_setup.dart';

void main() async {
  write('require :${hasRequire}');
  var options = await setup();
  write('loaded');
  final firebase = firebaseBrowser;

  App app;

  querySelector('#initialize').onClick.listen((_) async {
    write('initializing...');
    app = firebase.initializeApp(options: options);
    write('initialized ${app.name}');
  });

  querySelector('#delete').onClick.listen((_) async {
    if (app != null) {
      write('deleing...');
      await app.delete();
      write('deleted');
    }
  });
}
