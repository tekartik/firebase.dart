import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart' hide log;
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_firebase/firebase.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';

import 'package:tekartik_firebase_sim/src/firebase_sim_server.dart';
import 'package:tekartik_rpc/rpc_client.dart';
import 'log_utils.dart';

var debugFirebaseSimClient = false; // devWarning(true);

void _log(Object? message) {
  log('firebase_sim_client', message);
}

/// Compat
typedef AppSim = FirebaseAppSim;

/// We have one client per app
class FirebaseAppSim with FirebaseAppMixin {
  final FirebaseSim admin;
  bool deleted = false;
  final String _name;

  @override
  Firebase get firebase => admin;

  Completer<FirebaseSimClient>? readyCompleter;

  Future<FirebaseSimClient> get simClient async {
    if (readyCompleter == null) {
      readyCompleter = Completer();

      var simClient = FirebaseSimClient.connect(admin.uri,
          webSocketChannelClientFactory: admin.clientFactory);
      var adminInitializeAppData = AdminInitializeAppData()
        ..projectId = options.projectId
        ..name = name;
      try {
        await simClient.sendRequest<void>(FirebaseSimCoreService.serviceName,
            methodAdminInitializeApp, adminInitializeAppData.toMap());
        readyCompleter!.complete(simClient);
      } catch (e) {
        readyCompleter!.completeError(e);
      }
    }
    return readyCompleter!.future;
  }

  FirebaseAppSim(this.admin, this.options, this._name) {
    //_name ??= firebaseAppNameDefault;
  }

  @override
  Future delete() async {
    if (!deleted) {
      deleted = true;
      await closeServices();
    }
  }

  @override
  String get name => _name;

  @override
  final AppOptions options;

  // basic ping feature with console display
  Future ping() async {
    var simClient = await this.simClient;
    await simClient.sendRequest<void>(
        FirebaseSimCoreService.serviceName, methodPing, null);
  }

  // use the rpc
  Future<String?> getAppName() async {
    var simClient = await this.simClient;
    return await simClient.sendRequest(
        FirebaseSimCoreService.serviceName, methodAdminGetAppName, null);
  }
}

String get _defaultAppName => firebaseAppNameDefault;
String get _defaultProjectId => 'sim';

/// Firebase sim
class FirebaseSim with FirebaseMixin {
  final WebSocketChannelClientFactory? clientFactory;
  final Uri uri;

  FirebaseSim({this.clientFactory, Uri? uri})
      : uri = uri ?? Uri.parse('ws://localhost:$firebaseSimDefaultPort');

  final _apps = <String, AppSim>{};

  @override
  App initializeApp({AppOptions? options, String? name}) {
    name ??= _defaultAppName;
    var app = FirebaseAppSim(
        this, options ?? AppOptions(projectId: _defaultProjectId), name);
    _apps[name] = app;
    return app;
  }

  @override
  App app({String? name}) {
    name ??= _defaultAppName;
    return _apps[name]!;
  }
}

const requestTimeoutDuration = Duration(seconds: 15);

class _FirebaseSimClient implements FirebaseSimClient {
  final RpcClient rpcClient;

  _FirebaseSimClient({required this.rpcClient});

  @override
  Future<T> sendRequest<T>(String service, String method, Object? param) async {
    T t;
    if (debugFirebaseSimClient) {
      _log('request: $method $param');
    }
    try {
      t = await rpcClient.sendServiceRequest<T>(service, method, param);
      if (debugFirebaseSimClient) {
        _log('response $t');
      }
    } on json_rpc.RpcException catch (e) {
      // devPrint('ERROR ${e.runtimeType} $e ${e.message} ${e.data}');
      if (isDebug) {
        _log(e);
        _log('sending $method $param');
      }
      throw e.message;
    }
    return t;
  }

  @override
  Future close() async {
    await rpcClient.close();
  }
}

/// Firebase sim client
abstract class FirebaseSimClient {
  static FirebaseSimClient connect(Uri uri,
      {WebSocketChannelClientFactory? webSocketChannelClientFactory}) {
    var rpcClient = AutoConnectRpcClient.autoConnect(uri,
        webSocketChannelClientFactory: webSocketChannelClientFactory);
    return _FirebaseSimClient(rpcClient: rpcClient);
  }

  /// Send a request
  Future<T> sendRequest<T>(String service, String method, Object? param);

  /// Close
  Future<void> close();
}
