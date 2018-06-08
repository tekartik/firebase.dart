import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';

Firebase getFirebaseSim(
    {WebSocketChannelClientFactory clientFactory, String url}) {
  clientFactory ??= webSocketChannelClientFactoryIo;
  Firebase firebase = new FirebaseSim(clientFactory: clientFactory, url: url);
  return firebase;
}
