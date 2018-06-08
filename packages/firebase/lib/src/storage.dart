import 'dart:async';

abstract class Storage {
  Bucket bucket(String name);
}

abstract class Bucket {
  String get name;
  File file(String path);
  Future<bool> exists();
}

abstract class File {
  Future save(/* String | List<int> */ dynamic content);
  Future<bool> exists();
  Future<List<int>> download();
  Future delete();
}
