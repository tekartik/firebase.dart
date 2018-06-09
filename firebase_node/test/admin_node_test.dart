@TestOn('node')
library tekartik_firebase_server_node.node_test;

import 'package:test/test.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_node/firebase_node.dart';

void main() {
  group('node', () {
    App app = firebaseNode.initializeApp();

    tearDownAll(() {
      return app.delete();
    });

    // there is no name on node
    // runApp(firebaseNode, app);
  });
}
