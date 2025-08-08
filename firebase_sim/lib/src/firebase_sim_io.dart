// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';

// ignore: depend_on_referenced_packages
import 'package:tekartik_web_socket_io/web_socket_io.dart';
export 'package:tekartik_firebase_sim/firebase_sim.dart';

FirebaseSim getFirebaseSimIo({
  WebSocketChannelClientFactory? clientFactory,
  Uri? uri,
  String? localPath,
}) {
  clientFactory ??= webSocketChannelClientFactoryIo;
  return getFirebaseSim(
    clientFactory: clientFactory,
    uri: uri,
    localPath: localPath,
  );
}
