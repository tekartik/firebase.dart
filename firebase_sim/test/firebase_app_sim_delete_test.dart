@TestOn('vm')
library;

import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:test/test.dart';

import 'test_common.dart';

Future main() async {
  var testContext = await initTestContextSim();

  tearDownAll(() async {
    await close(testContext);
  });

  test('delete closes the connection of the app', () async {
    var app =
        await testContext.firebase.initializeAppAsync(name: 'delete_test')
            as FirebaseAppSim;
    await app.ping();
    var simClient = await app.simClient;
    await app.delete();
    // The connection is closed (it kept a program alive before).
    await expectLater(
      simClient
          .sendRequest<void>(
            FirebaseSimServerCoreService.serviceName,
            methodPing,
            null,
          )
          .timeout(const Duration(seconds: 5)),
      throwsA(isNot(isA<TimeoutException>())),
    );
  }, timeout: const Timeout(Duration(seconds: 30)));
}
