@JS()
library tekartik_firebase_node.storage_binding;

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';

@JS()
@anonymous
abstract class File {
  external Promise save(dynamic data);
  external Promise exists();
  external Promise download();
  external Promise delete();
}

@JS()
@anonymous
abstract class Bucket {
  external String get name;
  external File file(String path);
  external Promise exists();
}

@JS()
@anonymous
abstract class Storage {
  external Bucket bucket([String name]);
}

@JS()
@anonymous
abstract class StorageApp {
  external Storage storage();
}

@JS()
@anonymous
class Error {
  dynamic errors;
  dynamic code;
  String message;
}
