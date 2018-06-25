import 'dart:async';
import 'package:js/js_util.dart';
import 'package:node_interop/util.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/storage.dart';
import 'package:tekartik_firebase_node/src/storage_bindings.dart' as native;

class StorageNode implements Storage {
  final native.Storage nativeInstance;

  StorageNode(this.nativeInstance);

  @override
  Bucket bucket([String name]) {
    native.Bucket nativeBucket;
    if (name == null) {
      nativeBucket = callMethod(nativeInstance, "bucket", []) as native.Bucket;
    } else {
      nativeBucket = nativeInstance.bucket(name);
    }
    return _wrapBucket(nativeBucket);
  }
}

class FileNode implements File {
  final native.File nativeInstance;

  FileNode(this.nativeInstance);

  @override
  Future save(data) => promiseToFuture(nativeInstance.save(data));

  @override
  Future<bool> exists() async {
    // Array with first bool as the response
    var fileExistsResponse =
        (await promiseToFuture(nativeInstance.exists())) as List;
    return fileExistsResponse[0] as bool;
  }

  @override
  Future<List<int>> download() async {
    // Array with first item as the response
    var downloadResponse =
        (await promiseToFuture(nativeInstance.download())) as List;
    return downloadResponse[0] as List<int>;
  }

  @override
  Future delete() => promiseToFuture(nativeInstance.delete());
}

class BucketNode implements Bucket {
  final native.Bucket nativeInstance;

  BucketNode(this.nativeInstance);

  @override
  File file(String path) => _wrapFile(nativeInstance.file(path));

  @override
  Future<bool> exists() =>
      promiseToFuture(nativeInstance.exists()).then((data) => data[0] as bool);

  @override
  String get name => nativeInstance.name;
}

BucketNode _wrapBucket(native.Bucket nativeInstance) =>
    nativeInstance != null ? new BucketNode(nativeInstance) : null;

FileNode _wrapFile(native.File nativeInstance) =>
    nativeInstance != null ? new FileNode(nativeInstance) : null;
