// ignore_for_file: deprecated_member_use_from_same_package, duplicate_ignore

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_browser/firebase_browser.dart';
import 'package:tekartik_firebase_browser/src/interop.dart';
import 'package:web/web.dart' as web;

import 'example_common.dart';
import 'example_setup.dart';

void main() async {
  write('require :$hasRequire');
  var options = await setup();
  write('loaded');
  // ignore: deprecated_member_use_from_same_package
  final firebase = firebaseBrowser;

  App? app;

  web.document.querySelector('#initialize')!.onClick.listen((_) async {
    write('initializing...');
    app = firebase.initializeApp(options: options);
    write('initialized ${app!.name}');
  });

  web.document.querySelector('#delete')!.onClick.listen((_) async {
    if (app != null) {
      write('deleting...');
      await app!.delete();
      write('deleted');
    }
  });

  web.document.querySelector('#get_app')!.onClick.listen((_) async {
    write('Getting...');
    try {
      app = firebase.app();
      write('Got ${app!.name}');
    } catch (e) {
      write('error $e');
    }
  });
}
