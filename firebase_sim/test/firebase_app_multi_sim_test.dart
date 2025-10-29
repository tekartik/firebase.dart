@TestOn('vm')
library;

import 'package:path/path.dart';
import 'package:tekartik_app_web_socket/web_socket.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  // debugFirebaseSimClient = devTrue;
  // debugFirebaseSimServer = devTrue;
  test('multi', () async {
    var testContext = await initTestContextSim(
      localPath: join('.local', 'multi1'),
    );
    var firebase2 = getFirebaseSim(
      clientFactory: webSocketChannelClientFactoryMemory,
      uri: Uri.parse(testContext.simServer.url),
      localPath: join('.local', 'multi2'),
    );
    var app1 =
        await testContext.firebase.initializeAppAsync() as FirebaseAppSim;
    var app2 = await firebase2.initializeAppAsync() as FirebaseAppSim;

    expect(app1.options.projectId, 'sim');
    expect(app2.options.projectId, 'sim');
    var code1 = await app1.getAppDelegateName();

    var code2 = await app2.getAppDelegateName();
    expect(code1, code2);
    var appName1 = await app1.getAppName();

    var appName2 = await app2.getAppName();
    expect(appName1, isNot(appName2));
  });
}
