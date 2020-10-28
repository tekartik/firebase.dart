@TestOn('node')
library tekartik_firebase_server_node.node_test;

import 'package:tekartik_firebase_node/firebase_node.dart';
import 'package:test/test.dart';

// GOOGLE_APPLICATION_CREDENTIALS must be defined in an environment variable
// pointing to the relevan json path
void main() {
  /*
  group('node', () {
    // there is no name on node
    runApp(firebaseNode, options: null);
  });
   */
  group('firebase admin', () {
    test('access token', () async {
      var app = firebaseNode.initializeApp(name: 'admin');
      print(
          (await firebaseNode.credential.applicationDefault().getAccessToken())
              .data);
      print(app.options.projectId);
      await app.delete();
    });
  });
}
