import 'package:fs_shim/fs_shim.dart';
import 'package:tekartik_app_web_socket/web_socket.dart' as universal;
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_web_socket/web_socket.dart';

String get _defaultAppName => firebaseAppNameDefault;

String get _defaultProjectId => 'sim';

/// Default project ID for the tekartik firebase Sim.
String firebaseSimDefaultProjectId = _defaultProjectId;

/// Localhost base URL.
const firebaseSimLocalhostBaseUrl = 'ws://localhost';

/// The default port for the Firebase Simulator.
final int firebaseSimDefaultPort = 4996;

/// Get the default Firebase Simulator URL.
// @deprecated
String getFirebaseSimUrl({int? port}) {
  return getFirebaseSimLocalhostUri(port: port).toString();
}

/// Get the default Firebase Simulator port.
int getFirebaseSimPort([int? port]) {
  port ??= firebaseSimDefaultPort;
  return port;
}

/// Get the default Firebase Simulator URL.
Uri getFirebaseSimLocalhostUri({int? port}) {
  var foundPort = getFirebaseSimPort(port);
  return Uri.parse('$firebaseSimLocalhostBaseUrl:$foundPort');
}

/// Get firebase sim
FirebaseSim getFirebaseSim({
  @Deprecated('Do no use') Firebase? firebaseServer,
  WebSocketChannelClientFactory? clientFactory,
  Uri? uri,
  String? localPath,
}) {
  clientFactory ??= universal.webSocketChannelClientFactory;
  var firebase = _FirebaseClientSim(
    clientFactory: clientFactory,
    uri: uri,
    localPath: localPath,
  );
  return firebase;
}

/// Mixin for Firebase Sim.
mixin FirebaseSimMixin on FirebaseMixin {
  /// Close firebase
  Future<void> close() async {}
}

/// Firebase Sim interface.
abstract class FirebaseSim implements Firebase {
  /// Local path.
  String get localPath;

  /// Close firebase.
  Future<void> close();
}

/// Client sim
abstract class FirebaseClientSim implements FirebaseSim {
  /// Uri to connect to.
  Uri get uri;

  /// Client factory.
  WebSocketChannelClientFactory? get clientFactory;
}

/// Firebase sim
class _FirebaseClientSim
    with FirebaseWithAppsMixin, FirebaseMixin, FirebaseSimMixin
    implements FirebaseClientSim {
  /// The Firebase server when testing both locally.
  Firebase? firebaseServer;
  String? _localPath;

  /// Local path
  @override
  String get localPath => _localPath!;

  /// Client factory for WebSocket connections.
  @override
  final WebSocketChannelClientFactory? clientFactory;

  /// The URI for the Firebase Simulator.
  @override
  final Uri uri;

  _FirebaseClientSim({this.clientFactory, Uri? uri, String? localPath})
    : uri = uri ?? Uri.parse('ws://localhost:$firebaseSimDefaultPort') {
    _localPath =
        localPath ??
        fileSystemDefault.path.join(
          '.dart_tool',
          'tekartik_firebase_sim_client_local',
        );
  }

  FirebaseAppSim _initializeApp({FirebaseAppOptions? options, String? name}) {
    name ??= _defaultAppName;
    checkAppNameUninitialized(name);
    var app = FirebaseAppSim(
      this,
      options ?? AppOptions(projectId: _defaultProjectId),
      name,
    );
    return addApp(app);
  }

  @override
  FirebaseAppSim initializeApp({FirebaseAppOptions? options, String? name}) {
    return _initializeApp(options: options, name: name);
  }

  @override
  Future<FirebaseAppSim> initializeAppAsync({
    FirebaseAppOptions? options,
    String? name,
  }) async {
    var app = _initializeApp(options: options, name: name);
    await app.simClient;
    return app;
  }
}
