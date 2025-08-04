import 'package:fs_shim/fs_shim.dart';
import 'package:tekartik_app_web_socket/web_socket.dart' as universal;
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_web_socket/web_socket.dart';

String get _defaultAppName => firebaseAppNameDefault;

String get _defaultProjectId => 'sim';

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
  String? localPath,
}) {
  clientFactory ??= universal.webSocketChannelClientFactory;
  Firebase firebase = FirebaseSim(
    clientFactory: clientFactory,
    uri: uri,
    localPath: localPath,
  );
  return firebase;
}

/// Firebase sim
class FirebaseSim with FirebaseMixin {
  String? _localPath;

  /// Local path
  String get localPath => _localPath!;

  final WebSocketChannelClientFactory? clientFactory;
  final Uri uri;

  FirebaseSim({this.clientFactory, Uri? uri, String? localPath})
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
