// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket_io/web_socket_io.dart';

Firebase getFirebaseSimIo(
    {WebSocketChannelClientFactory? clientFactory, Uri? uri}) {
  clientFactory ??= webSocketChannelClientFactoryIo;
  Firebase firebase = FirebaseSim(clientFactory: clientFactory, uri: uri);
  return firebase;
}

Firebase getFirebaseSim(
        {WebSocketChannelClientFactory? clientFactory, Uri? uri}) =>
    getFirebaseSimIo(clientFactory: clientFactory, uri: uri);
