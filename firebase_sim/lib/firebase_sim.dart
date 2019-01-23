final int firebaseSimDefaultPort = 4996;

String getFirebaseSimUrl({int port}) {
  port ??= firebaseSimDefaultPort;
  return "ws://localhost:${port}";
}
