import 'dart:core' hide Error;

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/map_utils.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_message.dart';
import 'package:tekartik_rpc/rpc_server.dart';

import '../firebase_sim.dart';
import 'log_utils.dart';

var debugFirebaseSimServer = false; // devWarning(true);
void _log(Object? message) {
  log('firebase_sim_client', message);
}

Future<FirebaseSimServer> firebaseSimServe(
  Firebase firebase, {
  WebSocketChannelServerFactory? webSocketChannelServerFactory,
  List<FirebaseSimPlugin>? plugins,
  int? port,
}) async {
  port ??= firebaseSimDefaultPort;
  var services = [
    FirebaseSimServerCoreService(),
    if (plugins != null) ...plugins.map((plugin) => plugin.simService),
  ];
  var rpcServer = await RpcServer.serve(
    port: port,
    webSocketChannelServerFactory: webSocketChannelServerFactory,
    services: services,
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

class FirebaseSimServer {
  int lastAppId = 0;
  final Firebase? firebase;

  FirebaseApp? getAppByProjectId(String projectId) {
    var app = _appByProjectId[projectId];
    // print('getAppByProjectId $projectId -> $app');
    return app;
  }

  void setProjectIdApp(String projectId, FirebaseApp app) {
    // print('setProjectIdApp $projectId -> $app');
    _appByProjectId[projectId] = app;
  }

  /// Map of projectId to FirebaseApp
  final _appByProjectId = <String, FirebaseApp>{};
  final List<FirebaseSimPlugin> _plugins = [];
  final RpcServer rpcServer;

  void addPlugin(FirebaseSimPlugin plugin) {
    _plugins.add(plugin);
  }

  String get url => rpcServer.url;
  Uri get uri => Uri.parse(url);

  FirebaseSimServer(this.firebase, this.rpcServer);

  Future close() async {
    await rpcServer.close();
  }
}

@Deprecated('use FirebaseSimServerServiceBase instead')
typedef FirebaseSimServiceBase = FirebaseSimServerServiceBase;

/// Sim server service definition
abstract class FirebaseSimServerService implements RpcService {
  /// Sim server, typically instantiated by server upon creation
  FirebaseSimServer get simServer;

  /// For late initialization
  set simServer(FirebaseSimServer simServer);
}

/// Base server service
abstract class FirebaseSimServerServiceBase extends RpcServiceBase
    implements FirebaseSimServerService {
  @override
  late final FirebaseSimServer simServer;

  FirebaseSimServerServiceBase(super.name);
}

var firebaseSimServerExpando = Expando<FirebaseSimServerChannel>();

class FirebaseSimServerCoreService extends FirebaseSimServerServiceBase {
  static const serviceName = 'firebase_core';

  FirebaseSimServerCoreService() : super(serviceName);

  @override
  FutureOr<Object?> onCall(RpcServerChannel channel, RpcMethodCall methodCall) {
    var simServerChannel = firebaseSimServerExpando[channel] ??=
        FirebaseSimServerChannel(simServer);
    switch (methodCall.method) {
      case methodPing:
        var params = methodCall.arguments;
        if (debugFirebaseSimServer) {
          _log('ping rcv: $params');
        }
        var result = params;
        if (debugFirebaseSimServer) {
          _log('ping snd: $params');
        }
        return result;

      case methodAdminInitializeApp:
        return simServerChannel.handleAdminInitializeApp(
          anyAsMap(methodCall.arguments!),
        );
      case methodAdminGetServerAppHashCode:
        return simServerChannel.handleAdminGetServerAppHashCode();
      case methodAdminGetAppName:
        return simServerChannel.app!.name;
    }

    return super.onCall(channel, methodCall);
  }
}

class FirebaseSimServerChannel {
  final FirebaseSimServer _simServer;
  FirebaseApp? app;
  FirebaseSimServerChannel(this._simServer);

  Map<String, Object?>? handleAdminInitializeApp(Map<String, dynamic> param) {
    var adminInitializeAppData = AdminInitializeAppData()..fromMap(param);

    var projectId = adminInitializeAppData.projectId!;

    /// Share the app if possible
    var options = AppOptions(projectId: projectId);
    app = _simServer.getAppByProjectId(projectId);
    if (app == null) {
      app = _simServer.firebase!.initializeApp(
        options: options,
        name: adminInitializeAppData.name,
      );
      _simServer.setProjectIdApp(projectId, app!);
    }

    return null;
  }

  // tmp
  Map<String, Object?>? handleAdminGetServerAppHashCode() {
    return {'hashCode': app!.hashCode};
  }
}

abstract class FirebaseSimPlugin {
  FirebaseSimServerService get simService;
  //FirebaseSimPluginServer register(App app, json_rpc.Server rpcServer);
}
