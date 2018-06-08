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
  final StorageIo storage;
  final String name;

  String get localPath => join(storage.ioApp.localPath, name);

  BucketIo(this.storage, this.name);

  @override
  File file(String path) => new FileIo(this, path);

  @override
  Future<bool> exists() async {
    // TODO: implement exists
    return true;
  }
}

class StorageIo implements Storage {
  final io.AppSembast ioApp;

  StorageIo(this.ioApp);

  @override
  Bucket bucket([String name]) => new BucketIo(this, name);
}