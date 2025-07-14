import 'package:tekartik_app_web_socket/web_socket.dart' as universal;
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_rpc/rpc_client.dart';
import 'package:tekartik_web_socket/web_socket.dart';

import 'firebase_sim.dart';

export 'src/firebase_sim.dart' show FirebaseSim;
export 'src/firebase_sim_client.dart' show FirebaseAppSim;

/// The default port for the Firebase Simulator.
final int firebaseSimDefaultPort = 4996;

/// Get the default Firebase Simulator URL.
String getFirebaseSimUrl({int? port}) {
  port ??= firebaseSimDefaultPort;
  return 'ws://localhost:$port';
}

/// Get firebase sim
Firebase getFirebaseSim({
  WebSocketChannelClientFactory? clientFactory,
  Uri? uri,
}) {
  clientFactory ??= universal.webSocketChannelClientFactory;
  Firebase firebase = FirebaseSim(clientFactory: clientFactory, uri: uri);
  return firebase;
}
