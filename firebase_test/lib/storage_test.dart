import 'package:tekartik_firebase/firebase.dart';
import 'package:test/test.dart';

void run(Firebase firebase) {
  App app = firebase.initializeApp();

  tearDownAll(() {
    return app.delete();
  });

  runApp(app);
}

String defaultBucketName = "tekartik-free-dev.appspot.com";
runApp(App app) {
  group('storage', () {
    var storage = app.storage();
    test('storage', () {
      var storage = app.storage();
      expect(storage, isNotNull);
    });

    group('bucket', () {
      test('default_bucket', () {
        var bucket = app.storage().bucket();
        expect(bucket, isNotNull);
        print(bucket.name);
        expect(bucket.name, isNotNull);
      });

      test('bucket', () {
        var bucket = app.storage().bucket("test");
        expect(bucket, isNotNull);
        expect(bucket.name, "test");
      });
    });

    group('file', () {
      var bucket = storage.bucket(defaultBucketName);
      test('exists', () async {
        var file = bucket.file("dummy-file-that-should-not-exists");
        expect(await file.exists(), isFalse);
      });

      test('save_download_delete', () async {
        var file = bucket.file("file.txt");
        await file.save("simple content");
        expect(await file.exists(), isTrue);
        expect(
            new String.fromCharCodes(await file.download()), "simple content");
        await file.delete();
      });
    });
  });
}
