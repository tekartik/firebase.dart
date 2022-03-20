// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';

Firebase getFirebaseSimIo(
    {WebSocketChannelClientFactory? clientFactory, String? url}) {
  clientFactory ??= webSocketChannelClientFactoryIo;
  Firebase firebase = FirebaseSim(clientFactory: clientFactory, url: url);
  return firebase;
}

Firebase getFirebaseSim(
        {WebSocketChannelClientFactory? clientFactory, String? url}) =>
    getFirebaseSimIo(clientFactory: clientFactory, url: url);
