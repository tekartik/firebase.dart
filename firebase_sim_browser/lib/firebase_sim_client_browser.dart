import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim_browser/firebase_sim_client_browser.dart';
import 'package:tekartik_web_socket/web_socket.dart';

export 'package:tekartik_firebase_sim/firebase_sim_client.dart';
export 'package:tekartik_web_socket_browser/web_socket_browser.dart'
    show webSocketClientChannelFactoryBrowser;

Firebase getFirebaseSimBrowser(
    {WebSocketChannelClientFactory? clientFactory, String? url}) {
  clientFactory ??= webSocketClientChannelFactoryBrowser;
  Firebase firebase = FirebaseSim(clientFactory: clientFactory, url: url);
  return firebase;
}
