/// The default port for the Firebase Simulator.
final int firebaseSimDefaultPort = 4996;

/// Get the default Firebase Simulator URL.
String getFirebaseSimUrl({int? port}) {
  port ??= firebaseSimDefaultPort;
  return 'ws://localhost:$port';
}
