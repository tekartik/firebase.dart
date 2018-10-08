import 'package:test/test.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_web_socket/web_socket.dart';

//import 'package:tekartik_serial_wss_client/channel/channel.dart';

main() {
  firebase_sim_ping_test_main(webSocketChannelFactoryMemory);
}

firebase_sim_ping_test_main(WebSocketChannelFactory channelFactory) {
  group("sim", () {
    FirebaseSimServer simServer;
    FirebaseSimClient simClient;

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
      var request = simClient.newRequest(methodPing);
      var response = await simClient.sendRequest(request);
      expect(response.id, request.id);
    });
  });
}
