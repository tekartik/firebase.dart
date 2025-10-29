@TestOn('vm')
library;

import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  // debugFirebaseSimClient = debugFirebaseSimServer = devTrue;
  var testContext = await initTestContextSim();
  run(testContext);

  tearDownAll(() async {
    await close(testContext);
  });
}

void run(TestContext testContext) {
  test('init/close', () async {
    var firebase = testContext.firebase;
    var app = firebase.initializeApp(name: 'test_sim') as FirebaseAppSim;
    expect(FirebaseApp.instance, app);
    expect(app.name, 'test_sim');
    expect(app.projectId, 'sim');
    var name = await app.getAppName();
    expect(name, equals('test_sim1'));
    var delegateName = await app.getAppDelegateName();
    expect(delegateName, equals('sim_DEFAULT'));
    await app.delete();
  });
}
