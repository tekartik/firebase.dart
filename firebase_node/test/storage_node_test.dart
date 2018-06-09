@TestOn('node')
library tekartik_firebase_server_node.storage__test;

import 'package:node_interop/node_interop.dart';
import 'package:node_interop/util.dart';
import 'package:tekartik_firebase/firebase.dart' show App;
import 'package:tekartik_firebase_node/firebase_node.dart' show firebaseNode;
import 'package:tekartik_firebase_test/storage_test.dart';
import 'package:test/test.dart';

Map errorToMap(e) {
  var map = <String, dynamic>{};
  for (var key in objectKeys(e)) {
    //print("$key ${e[key]}");
    print(key);
    print(getProperty(e, key));
    //map[key] = e[key];
  }
  return map;
}

void main() {
  group('node', () {
    App app = firebaseNode.initializeApp();

    tearDownAll(() {
      return app.delete();
    });

    /*
    test('save', () async {
      var bucket = app.storage().bucket("test");
      print("exists ${await bucket.exists()}");
      if (!await bucket.exists()) {
        await bucket.create();
      }
      var file = bucket.file("file");
      try {
        await file.save('content');
      } catch (e) {
        print(objectKeys(e));
        print(e);
        print(errorToMap(e));
      }
    }, skip: true);
    */

    runApp(app);
  });
}
