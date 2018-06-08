import 'dart:async';
import 'dart:core' hide Error;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server.dart';
import 'package:tekartik_web_socket/web_socket.dart';
export 'firebase_sim.dart' show firebaseSimDefaultPort;

Future<FirebaseSimServer> serve(
    Firebase firebase, WebSocketChannelFactory channelFactory,
    {int port}) async {
  var server = await channelFactory.server.serve<String>(port: port);
  var simServer = new FirebaseSimServer(firebase, server);
  return simServer;
}

class FirebaseSimServer {
  int lastAppId = 0;
  final Firebase firebase;
  final List<FirebaseSimServerClient> clients = [];
  final WebSocketChannelServer<String> webSocketChannelServer;

  String get url => webSocketChannelServer.url;

  FirebaseSimServer(this.firebase, this.webSocketChannelServer) {
    webSocketChannelServer.stream.listen((clientChannel) {
      var client = new FirebaseSimServerClient(this, clientChannel);
      clients.add(client);
    });
  }

  Future close() async {
    // stop allowing clients
    await webSocketChannelServer.close();
    // Close existing clients
    for (var client in clients) {
      await client.close();
    }
  }
}
