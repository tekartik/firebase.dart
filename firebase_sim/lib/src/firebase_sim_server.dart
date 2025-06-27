import 'dart:core' hide Error;

import 'package:tekartik_common_utils/common_utils_import.dart' hide log;
import 'package:tekartik_common_utils/map_utils.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_rpc/rpc_server.dart';

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
  var services = [
    FirebaseSimCoreService(),
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

abstract class FirebaseSimServiceBase extends RpcServiceBase {
  late final FirebaseSimServer simServer;

  FirebaseSimServiceBase(super.name);
}

var firebaseSimServerExpando = Expando<FirebaseSimServerChannel>();

class FirebaseSimCoreService extends FirebaseSimServiceBase {
  static const serviceName = 'firebase_core';

  FirebaseSimCoreService() : super(serviceName);

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
  /*
  final List<FirebaseSimPluginServer> _pluginClients = [];

  FirebaseSimServerChannel(this._server, WebSocketChannel<String> channel)
      : _rpcServer = json_rpc.Server(channel) {
    // Specific method for getting server info upon start
    _rpcServer.registerMethod(methodAdminInitializeApp,
        (json_rpc.Parameters parameters) async {
      return handleAdminInitializeApp(_mapParams(parameters)!);
    });
    _rpcServer.registerMethod(methodAdminGetAppName,
        (json_rpc.Parameters parameters) async {
      return _app!.name;
    });
    _rpcServer.registerMethod(methodPing, (json_rpc.Parameters parameters) {
      if (debugFirebaseSimServer) {
        _log('ping rcv: $parameters');
      }
      var result = _mapParams(parameters);
      if (debugFirebaseSimServer) {
        _log('ping snd: $result');
      }
      return result;
    });


    _rpcServer.listen();
  }
  */
  Map<String, dynamic>? handleAdminInitializeApp(Map<String, dynamic> param) {
    var adminInitializeAppData = AdminInitializeAppData()..fromMap(param);
    var options = AppOptions(projectId: adminInitializeAppData.projectId);
    app = _simServer.firebase!.initializeApp(
      options: options,
      name: adminInitializeAppData.name,
    );
    // app.firestore().settings(FirestoreSettings(timestampsInSnapshots: true));
    // var snapshot = app.firestore().doc(firestoreSetData.path).get();
    /*
    for (var plugin in _server._plugins) {
      var client = plugin.register(_app!, _rpcServer);
      _pluginClients.add(client);
    }*/
    return null;
  }

  /*
  final FirebaseSimServer _server;
  final json_rpc.Server _rpcServer;

  Future close() async {
    for (var client in _pluginClients) {
      await client.close();
    }
  }*/
}
/*
abstract class FirebaseSimPluginServer {
  Future close();
}*/

abstract class FirebaseSimPlugin {
  FirebaseSimServiceBase get simService;
  //FirebaseSimPluginServer register(App app, json_rpc.Server rpcServer);
}
