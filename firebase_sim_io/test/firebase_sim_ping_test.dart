@TestOn('vm')
library tekartik_firebase_sim_io.firebase_sim_ping_test;

import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket/web_socket.dart';
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
      var server = await channelFactory.server.serve<String>();
      simServer = FirebaseSimServer(null, server);
    });

    tearDownAll(() async {});

    setUp(() {
      var client = channelFactory.client
          .connect<String>(simServer.webSocketChannelServer.url);
      simClient = FirebaseSimClient(client);
    });
    test('ping', () async {
      await simClient.sendRequest<void>(methodPing);
    });
  });
}
