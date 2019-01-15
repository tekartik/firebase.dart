import 'dart:async';
import 'dart:core' hide Error;

import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:meta/meta.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_web_socket/web_socket.dart';

// for debugging
//@deprecated
//set debugSimServerMessage(bool debugMessage) => _debugMessage = debugMessage;
//bool _debugMessage = false;

Future<FirebaseSimServer> serve(
    Firebase firebase, WebSocketChannelFactory channelFactory,
    {int port}) async {
  var server = await channelFactory.server.serve<String>(port: port);
  var simServer = FirebaseSimServer(firebase, server);
  return simServer;
}

class FirebaseSimServer {
  int lastAppId = 0;
  final Firebase firebase;

  final List<FirebaseSimPlugin> _plugins = [];
  final List<FirebaseSimServerChannel> _channels = [];
  final WebSocketChannelServer<String> webSocketChannelServer;

  void addPlugin(FirebaseSimPlugin plugin) {
    _plugins.add(plugin);
  }

  String get url => webSocketChannelServer.url;

  FirebaseSimServer(this.firebase, this.webSocketChannelServer) {
    webSocketChannelServer.stream.listen((clientChannel) {
      var channel = FirebaseSimServerChannel(this, clientChannel);
      _channels.add(channel);
    });
  }

  Future close() async {
    // stop allowing clients
    await webSocketChannelServer.close();
    // Close existing clients
    for (var channel in _channels) {
      await channel.close();
    }
  }
}

abstract class FirebaseSimMixin {
  WebSocketChannel<String> get webSocketChannel;

  // default
  // check overrides if this changes
  Future close() async {
    await closeMixin();
  }

  Future closeMixin() async {
    await webSocketChannel.sink.close();
  }

  // called internally
  @protected
  void init() {
    /*
    webSocketChannel.stream.listen((String data) {
      var message = Message.parseMap(json.decode(data) as Map<String, dynamic>);
      handleMessage(message);
    });
    */
  }
}

Map<String, dynamic> _mapParams(json_rpc.Parameters parameters) {
  return (parameters.value as Map)?.cast<String, dynamic>();
}

class FirebaseSimServerChannel {
  App _app;
  final List<FirebaseSimPluginClient> _pluginClients = [];

  FirebaseSimServerChannel(this._server, WebSocketChannel<String> channel)
      : _rpcServer = json_rpc.Server(channel) {
    // Specific method for getting server info upon start
    _rpcServer.registerMethod(methodAdminInitializeApp,
        (json_rpc.Parameters parameters) async {
      return handleAdminInitializeApp(_mapParams(parameters));
    });
    _rpcServer.registerMethod(methodAdminGetAppName,
        (json_rpc.Parameters parameters) async {
      return _app.name;
    });
    _rpcServer.registerMethod(methodPing, (json_rpc.Parameters parameters) {
      return _mapParams(parameters);
    });
    /*
    // Specific method for deleting a database
    _rpcServer.registerMethod(methodDeleteDatabase,
            (json_rpc.Parameters parameters) async {
          if (_notifyCallback != null) {
            _notifyCallback(false, methodDeleteDatabase, parameters.value);
          }
          await databaseFactory
              .deleteDatabase((parameters.value as Map)[keyPath] as String);
          if (_notifyCallback != null) {
            _notifyCallback(true, methodDeleteDatabase, null);
          }
          return null;
        });
    // Specific method for creating a directory
    _rpcServer.registerMethod(methodCreateDirectory,
            (json_rpc.Parameters parameters) async {
          if (_notifyCallback != null) {
            _notifyCallback(false, methodCreateDirectory, parameters.value);
          }
          var path = await sqfliteContext
              .createDirectory((parameters.value as Map)[keyPath] as String);
          if (_notifyCallback != null) {
            _notifyCallback(true, methodCreateDirectory, path);
          }
          return path;
        });
    // Specific method for creating a directory
    _rpcServer.registerMethod(methodDeleteDirectory,
            (json_rpc.Parameters parameters) async {
          if (_notifyCallback != null) {
            _notifyCallback(false, methodDeleteDirectory, parameters.value);
          }
          var path = await sqfliteContext
              .deleteDirectory((parameters.value as Map)[keyPath] as String);
          if (_notifyCallback != null) {
            _notifyCallback(true, methodDeleteDirectory, path);
          }
          return path;
        });
    // Generic method
    _rpcServer.registerMethod(methodSqflite,
            (json_rpc.Parameters parameters) async {
          if (_notifyCallback != null) {
            _notifyCallback(false, methodSqflite, parameters.value);
          }
          var map = parameters.value as Map;
          dynamic result =
          await invokeMethod<dynamic>(map[keyMethod] as String, map[keyParam]);
          if (_notifyCallback != null) {
            _notifyCallback(true, methodSqflite, result);
          }
          return result;
        });
        */

    _rpcServer.listen();
  }

  Map<String, dynamic> handleAdminInitializeApp(Map<String, dynamic> param) {
    var adminInitializeAppData = AdminInitializeAppData()..fromMap(param);
    var options = AppOptions(
      projectId: adminInitializeAppData.projectId,
    );
    _app = _server.firebase
        .initializeApp(options: options, name: adminInitializeAppData.name);
    // app.firestore().settings(FirestoreSettings(timestampsInSnapshots: true));
    // var snapshot = app.firestore().doc(firestoreSetData.path).get();

    for (var plugin in _server._plugins) {
      var client = plugin.register(_app, _rpcServer);
      if (client != null) {
        _pluginClients.add(client);
      }
    }
    return null;
  }

  final FirebaseSimServer _server;
  final json_rpc.Server _rpcServer;

  Future close() async {
    for (var client in _pluginClients) {
      await client.close();
    }
  }
}

abstract class FirebaseSimPluginClient {
  Future close();
}

abstract class FirebaseSimPlugin {
  FirebaseSimPluginClient register(App app, json_rpc.Server rpcServer);
}
