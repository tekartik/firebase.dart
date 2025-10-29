import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket_io/web_socket_io.dart';

export 'package:tekartik_common_utils/common_utils_import.dart';
export 'package:tekartik_firebase_sim/firebase_sim_server.dart';
export 'package:tekartik_firebase_sim/firebase_sim_server_mixin.dart';

class TestContext {
  late FirebaseSimServer simServer;
  late Firebase firebase;
  Future<void> close() async {
    await simServer.close();
    //await firebase.close();
  }
}

// memory only
Future<TestContext> initTestContextSim({String? localPath}) async {
  var testContext = TestContext();
  // The server use firebase io
  testContext.simServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelFactoryMemory.server,
  );
  testContext.firebase = getFirebaseSim(
    clientFactory: webSocketChannelClientFactoryMemory,
    uri: Uri.parse(testContext.simServer.url),
    localPath: localPath,
  );
  return testContext;
}

Future close(TestContext testContext) async {
  await testContext.simServer.close();
}
