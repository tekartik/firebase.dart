// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_web.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket/web_socket.dart';

export 'package:tekartik_firebase_sim/firebase_sim_client.dart';
export 'package:tekartik_web_socket_browser/web_socket_browser.dart'
    show webSocketClientChannelFactoryBrowser;

Firebase getFirebaseSimWeb({
  WebSocketChannelClientFactory? clientFactory,
  Uri? uri,
}) {
  clientFactory ??= webSocketClientChannelFactoryBrowser;
  return getFirebaseSim(clientFactory: clientFactory, uri: uri);
}
