@TestOn('vm')
library;

import 'package:tekartik_firebase_local/firebase_local.dart';

import 'package:tekartik_firebase_sim/firebase_sim_server_mixin.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket_io/web_socket_io.dart';
import 'package:test/test.dart';

//import 'package:tekartik_serial_wss_client/channel/channel.dart';

void main() {
  firebaseSimPingTestMain(webSocketChannelFactoryIo);
}

void firebaseSimPingTestMain(WebSocketChannelFactory channelFactory) {
  group('sim', () {
    late FirebaseSimServer simServer;
    late FirebaseSimClient simClient;

    setUpAll(() async {
      simServer = await firebaseSimServe(
        FirebaseLocal(),
        webSocketChannelServerFactory: channelFactory.server,
        port: 0,
      );
    });

    tearDownAll(() async {
      await simClient.close();
      await simServer.close();
    });

    setUp(() {
      simClient = FirebaseSimClient.connect(simServer.uri);
    });
    test('ping', () async {
      await simClient.sendRequest<void>(
        FirebaseSimServerCoreService.serviceName,
        methodPing,
        null,
      );
    });
  });
}
