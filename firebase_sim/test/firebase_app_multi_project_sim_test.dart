@TestOn('vm')
library;

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';

import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  // debugFirebaseSimClient = devTrue;
  // debugFirebaseSimServer = devTrue;
  test('multi', () async {
    var testContext = await initTestContextSim(
      localPath: join('.local', 'multi_project'),
    );
    var firebase = testContext.firebase;
    var app1 =
        await firebase.initializeAppAsync(
              options: AppOptions(projectId: 'prj1'),
              name: 'fbprj1',
            )
            as FirebaseAppSim;
    var app2 =
        await firebase.initializeAppAsync(
              options: AppOptions(projectId: 'prj2'),
              name: 'fbprj2',
            )
            as FirebaseAppSim;

    expect(app1.options.projectId, 'prj1');
    expect(app2.options.projectId, 'prj2');
    var appDelegateName1 = await app1.getAppDelegateName();
    var appDelegateName2 = await app2.getAppDelegateName();
    expect(appDelegateName1, isNot(appDelegateName2));
    var appName1 = await app1.getAppName();
    var appName2 = await app2.getAppName();
    expect(appName1, isNot(appName2));
    await app1.delete();
    await app2.delete();

    try {
      appName1 = await app1.getAppName();
      fail('Should have failed');
    } catch (e) {
      expect(e, isNot(isA<TestFailure>()));
      // Expected
    }
    await testContext.close();
  });
}
