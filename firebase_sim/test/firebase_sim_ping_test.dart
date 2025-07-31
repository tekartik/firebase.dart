import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server.dart';
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:test/test.dart';

void main() {
  // debugSimServerMessage = true;
  firebaseSimPingTestMain(webSocketChannelFactoryMemory);
}

void firebaseSimPingTestMain(WebSocketChannelFactory channelFactory) {
  debugFirebaseSimClient = false; // devWa
  var firebase = FirebaseSim();
  group('sim', () {
    late FirebaseSimServer simServer;
    late FirebaseSimClient simClient;

    setUpAll(() async {
      simServer = await firebaseSimServe(
        firebase,
        webSocketChannelServerFactory: channelFactory.server,
      );
    });

    tearDownAll(() async {});

    setUp(() {
      simClient = FirebaseSimClient.connect(
        Uri.parse(simServer.url),
        webSocketChannelClientFactory: channelFactory.client,
      );
    });
    test('ping', () async {
      /*
      var request = simClient.newRequest(methodPing);
      var response = await simClient.sendRequest(request);
      expect(response.id, request.id);
      */
      await simClient.sendRequest<void>(
        FirebaseSimServerCoreService.serviceName,
        methodPing,
        null,
      );
    });
  });
}
