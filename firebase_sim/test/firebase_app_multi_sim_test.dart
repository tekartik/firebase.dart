@TestOn('vm')
library;

import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_app_web_socket/web_socket.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_message.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
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
    var code1 = (await (await app1.simClient).sendRequest<Map>(
      FirebaseSimServerCoreService.serviceName,
      methodAdminGetServerAppHashCode,
      null,
    ))['hashCode'];
    var code2 = (await (await app2.simClient).sendRequest<Map>(
      FirebaseSimServerCoreService.serviceName,
      methodAdminGetServerAppHashCode,
      null,
    ))['hashCode'];
    expect(code1, code2);
  });
}
