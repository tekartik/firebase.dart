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

/// The default port for the Firebase Simulator.
final int firebaseSimDefaultPort = 4996;

/// Get the default Firebase Simulator URL.
String getFirebaseSimUrl({int? port}) {
  port ??= firebaseSimDefaultPort;
  return 'ws://localhost:$port';
}

/// Get firebase sim
FirebaseSim getFirebaseSim({
  Firebase? firebaseServer,
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

abstract class FirebaseSim implements Firebase {
  String get localPath;
}

/// Client sim
abstract class FirebaseClientSim implements FirebaseSim {
  /// Uri to connect to.
  Uri get uri;

  WebSocketChannelClientFactory? get clientFactory;
}

/// Firebase sim
class _FirebaseClientSim with FirebaseMixin implements FirebaseClientSim {
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

  final _apps = <String, FirebaseAppSim>{};

  @override
  FirebaseApp initializeApp({FirebaseAppOptions? options, String? name}) {
    name ??= _defaultAppName;
    var app = FirebaseAppSim(
      this,
      options ?? AppOptions(projectId: _defaultProjectId),
      name,
    );
    _apps[name] = FirebaseMixin.latestFirebaseInstanceOrNull = app;
    return app;
  }

  @override
  App app({String? name}) {
    name ??= _defaultAppName;
    return _apps[name]!;
  }
}
