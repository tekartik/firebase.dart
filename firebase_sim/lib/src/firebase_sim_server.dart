import 'dart:core' hide Error;

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server_mixin.dart';

import 'firebase_sim.dart';
import 'firebase_sim_server_app.dart';
import 'firebase_sim_server_service.dart';
import 'log_utils.dart';

/// Debug flag for Firebase Sim Server.
var debugFirebaseSimServer = false; // devWarning(true);
void _log(Object? message) {
  log('firebase_sim_server', message);
}

class _RpcServiceLogger implements RpcService {
  final RpcService _service;

  _RpcServiceLogger(this._service);

  @override
  String get name => _service.name;

  static var _id = 0;
  @override
  Future<Object?> onCall(
    RpcServerChannel channel,
    RpcMethodCall methodCall,
  ) async {
    _id++;
    var method = methodCall.method;
    var params = methodCall.arguments;
    if (debugFirebaseSimServer) {
      _log('request[$_id]: $name:$method $params');
    }
    try {
      var result = await _service.onCall(channel, methodCall);
      if (debugFirebaseSimServer) {
        _log('response[$_id]: $result');
      }
      return result;
    } catch (e, s) {
      _log('error[$_id]: $e\n$s');
      rethrow;
    }
  }
}

/// Start Firebase sim server.
Future<FirebaseSimServer> firebaseSimServe(
  Firebase firebase, {
  WebSocketChannelServerFactory? webSocketChannelServerFactory,
  List<FirebaseSimPlugin>? plugins,
  int? port,
}) async {
  firebaseSimInitCvBuilders();
  port ??= firebaseSimDefaultPort;
  var services = [
    FirebaseSimServerCoreService(),
    if (plugins != null) ...plugins.map((plugin) => plugin.simService),
  ];
  var rpcServices = debugFirebaseSimServer
      ? services
            .map((service) => _RpcServiceLogger(service))
            .toList(growable: false)
      : services;
  var rpcServer = await RpcServer.serve(
    port: port,
    webSocketChannelServerFactory: webSocketChannelServerFactory,
    services: rpcServices,
  );
  var simServer = FirebaseSimServer(firebase, rpcServer);
  for (var service in services) {
    service.simServer = simServer;
  }
  if (plugins != null) {
    for (var plugin in plugins) {
      simServer.addPlugin(plugin);
    }
  }
  return simServer;
}

/// Only for implementation
extension FirebaseSimServerMixinExt on FirebaseSimServer {
  /// Init for app.
  FutureOr<void> initForApp(FirebaseApp app) {
    if (!isPluginsInitialized(app)) {
      return _initLock.synchronized(() async {
        if (!isPluginsInitialized(app)) {
          for (var plugin in _plugins) {
            if (debugFirebaseSimServer) {
              _log('Initializing plugin ${plugin.runtimeType} for app $app');
            }
            var result = plugin.initForApp(app);
            if (result is Future) {
              await result;
            }
          }

          setPluginsInitialized(app, true);
        }
      });
    }
  }

  /// Whether plugins are initialized for app.
  bool isPluginsInitialized(FirebaseApp app) {
    return _pluginsInitialized.contains(app);
  }

  /// Set plugins initialized for app.
  void setPluginsInitialized(FirebaseApp app, bool initialized) {
    if (!initialized) {
      _pluginsInitialized.remove(app);
      return;
    }
    _pluginsInitialized.add((app));
  }

  /// Get app by project ID.
  FirebaseApp? getAppByProjectId(String projectId) {
    var app = _appByProjectId[projectId];
    // print('getAppByProjectId $projectId -> $app');
    return app;
  }

  /// Set project ID app.
  void setProjectIdApp(String projectId, FirebaseApp app) {
    // print('setProjectIdApp $projectId -> $app');
    _appByProjectId[projectId] = app;
  }
}

class _FirebaseSimServer extends FirebaseSimServer {
  var firebaseSimServerExpando = Expando<FirebaseSimServerChannel>();
  final projectsByProjectId = <String, FirebaseSimServerProject>{};
  _FirebaseSimServer(super.firebase, super.rpcServer) : super._();

  /// Get or create channel
  @override
  FirebaseSimServerChannel channel(RpcServerChannel channel) {
    return firebaseSimServerExpando[channel] ??= FirebaseSimServerChannel(
      this,
      channel,
    );
  }
}

/// Firebase Sim Server.
abstract class FirebaseSimServer {
  final _initLock = Lock();
  //int _lastAppId = 0;
  /// Firebase instance.
  final Firebase firebase;

  /// Set of initialized plugins
  final _pluginsInitialized = <FirebaseApp>{};

  /// Initialize app from server side
  /// This could trigger listening to http functions
  Future<void> initializeAppAsync({FirebaseAppOptions? options}) async {
    options ??= FirebaseAppOptions();
    var projectId = options.projectId ?? firebaseSimDefaultProjectId;
    if (options.projectId == null) {
      options = FirebaseAppOptions(projectId: projectId);
    }
    var app = getAppByProjectId(projectId);
    if (app == null) {
      app = firebase.initializeApp(options: options);
      setProjectIdApp(projectId, app);
    }
    await initForApp(app);
  }

  /// Map of projectId to FirebaseApp
  final _appByProjectId = <String, FirebaseApp>{};
  final List<FirebaseSimPlugin> _plugins = [];

  /// RPC server instance.
  final RpcServer rpcServer;

  /// Add plugin.
  void addPlugin(FirebaseSimPlugin plugin) {
    _plugins.add(plugin);
  }

  /// Server URL.
  String get url => rpcServer.url;

  /// Client websocket uri
  Uri get uri => Uri.parse(url);

  FirebaseSimServer._(this.firebase, this.rpcServer);

  /// Constructor.
  factory FirebaseSimServer(Firebase firebase, RpcServer rpcServer) =>
      _FirebaseSimServer(firebase, rpcServer);

  /// Close server.
  Future close() async {
    await rpcServer.close();
  }

  /// Get channel.
  FirebaseSimServerChannel channel(RpcServerChannel channel);
}
