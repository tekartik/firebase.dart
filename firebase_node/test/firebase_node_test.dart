@TestOn('node')
library tekartik_firebase_server_node.node_test;

import 'package:test/test.dart';
import 'package:tekartik_firebase_node/firebase_node.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';

void main() {
  group('node', () {
    // there is no name on node
    runApp(firebaseNode, options: null);
  });
}
