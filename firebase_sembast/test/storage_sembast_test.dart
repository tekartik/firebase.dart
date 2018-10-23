@TestOn('vm')
library tekartik_firebase_sembast.storage_io_test;

import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sembast/firebase_sembast_io.dart';
import 'package:tekartik_firebase_sembast/src/storage_sembast.dart';
import 'package:tekartik_firebase_test/storage_test.dart';
import 'package:test/test.dart';

void main() {
  App app = firebaseSembastIo.initializeApp();

  tearDownAll(() {
    return app.delete();
  });

  runApp(app);

  group('storage_io', () {
    test('bucket_no_name', () async {
      var bucketIo = app.storage().bucket() as BucketIo;
      expect(
          bucketIo.localPath, join(".dart_tool", "tekartik_firebase_sembast"));
    });
    test('default_bucket_local_path', () async {
      var old = firebaseSembastIoDefaultBucketLocalPath;
      try {
        firebaseSembastIoDefaultBucketLocalPath = "some_dir";
        var bucketIo = app.storage().bucket() as BucketIo;
        expect(bucketIo.localPath, "some_dir");
      } finally {
        // restore
        firebaseSembastIoDefaultBucketLocalPath = old;
      }
    });

    test('create_no_tree', () async {
      var fileIo = app.storage().bucket("test").file("test") as FileIo;

      // delete a top folder to force creating the tree again
      try {
        await io.Directory(fileIo.bucket.localPath).delete(recursive: true);
      } catch (_) {}
      expect(await fileIo.exists(), isFalse);
      await fileIo.save("test");
      expect(await fileIo.exists(), isTrue);
    });
  });
}
