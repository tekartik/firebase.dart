@TestOn('vm')
library tekartik_firebase_sembast.storage_io_test;

import 'dart:io' as io;

import 'package:tekartik_firebase/firebase.dart';
import 'package:test/test.dart';
import 'package:tekartik_firebase_sembast/firebase_sembast.dart';
import 'package:tekartik_firebase_sembast/src/storage_sembast.dart';
import 'package:tekartik_firebase_test/storage_test.dart';

void main() {
  App app = firebaseSembast.initializeApp();

  tearDownAll(() {
    return app.delete();
  });

  runApp(app);

  group('storage_io', () {
    test('create_no_tree', () async {
      var fileIo = app.storage().bucket("test").file("test") as FileIo;

      // delete a top folder to force creating the tree again
      try {
        await new io.Directory(fileIo.bucket.localPath).delete(recursive: true);
      } catch (_) {}
      expect(await fileIo.exists(), isFalse);
      await fileIo.save("test");
      expect(await fileIo.exists(), isTrue);
    });
  });
}
