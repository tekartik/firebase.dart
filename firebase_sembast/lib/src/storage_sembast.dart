import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:tekartik_firebase/storage.dart';
import 'package:tekartik_firebase_sembast/src/firebase_sembast.dart' as io;

class FileIo implements File {
  final BucketIo bucket;
  final String path;

  String get localPath => join(bucket.localPath, path);

  io.File get ioFile => new io.File(localPath);

  FileIo(this.bucket, this.path);

  @override
  Future save(content) async {
    _write() async {
      if (content is String) {
        await ioFile.writeAsString(content);
      } else {
        await ioFile.writeAsBytes(content as List<int>);
      }
    }

    try {
      await _write();
    } catch (_) {
      try {
        await ioFile.parent.create(recursive: true);
      } catch (_) {}
      // try again
      await _write();
    }
  }

  @override
  Future<List<int>> download() async {
    return await ioFile.readAsBytes();
  }

  @override
  Future<bool> exists() async {
    return await ioFile.exists();
  }

  @override
  Future delete() async {
    return await ioFile.delete();
  }
}

class BucketIo implements Bucket {
  final StorageSembast storage;
  final String name;

  String localPath;

  BucketIo(this.storage, this.name) {
    localPath = join(storage.ioApp.localPath, name);
  }

  @override
  File file(String path) => new FileIo(this, path);

  @override
  Future<bool> exists() async {
    // TODO: implement exists
    return true;
  }
}

class StorageSembast implements Storage {
  final io.AppSembast ioApp;

  StorageSembast(this.ioApp);

  @override
  Bucket bucket([String name]) {
    var bucket = new BucketIo(this, name);
    if (name == null && firebaseSembastIoDefaultBucketLocalPath != null) {
      bucket.localPath = firebaseSembastIoDefaultBucketLocalPath;
    }
    return bucket;
  }
}

// Allow overriding the default bucket location
String firebaseSembastIoDefaultBucketLocalPath;
