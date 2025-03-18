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
import 'package:tekartik_firebase_sim/rpc_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server.dart';
import 'package:tekartik_web_socket/web_socket.dart';
import 'firebase_sim_common.dart';

var debugFirebaseSimClient = false; // devWarning(true);

void _log(Object? message) {
  log('firebase_sim_client', message);
}

class AppSim with FirebaseAppMixin {
  final FirebaseSim admin;
  bool deleted = false;
  final String _name;

  @override
  Firebase get firebase => admin;
  // when ready
  WebSocketChannel<String>? webSocketChannel;
  Completer<FirebaseSimClient>? readyCompleter;

  Future<FirebaseSimClient> get simClient async {
    if (readyCompleter == null) {
      readyCompleter = Completer();
      webSocketChannel = admin.clientFactory!.connect(admin.url);
      var simClient = FirebaseSimClient(webSocketChannel);
      var adminInitializeAppData = AdminInitializeAppData()
        ..projectId = options.projectId
        ..name = name;
      try {
        await simClient.sendRequest<void>(
            methodAdminInitializeApp, adminInitializeAppData.toMap());
        readyCompleter!.complete(simClient);
      } catch (e) {
        readyCompleter!.completeError(e);
      }
    }
    return readyCompleter!.future;
  }

  AppSim(this.admin, this.options, this._name) {
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
    await simClient.sendRequest<void>(methodPing);
  }

  // use the rpc
  Future<String?> getAppName() async {
    var simClient = await this.simClient;
    return await simClient.sendRequest(methodAdminGetAppName);
  }
}

String get _defaultAppName => firebaseAppNameDefault;
String get _defaultProjectId => 'sim';

class FirebaseSim with FirebaseMixin {
  final WebSocketChannelClientFactory? clientFactory;
  final String url;

  FirebaseSim({this.clientFactory, String? url})
      : url = url ?? 'ws://localhost:$firebaseSimDefaultPort';

  final _apps = <String, AppSim>{};

  @override
  App initializeApp({AppOptions? options, String? name}) {
    name ??= _defaultAppName;
    var app =
        AppSim(this, options ?? AppOptions(projectId: _defaultProjectId), name);
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

class FirebaseSimClient extends Object with FirebaseSimMixin {
  final _notificationController = StreamController<Notification>.broadcast();

  Stream<Notification> get notificationStream => _notificationController.stream;
  @override
  final WebSocketChannel<String>? webSocketChannel;
  late json_rpc.Client rpcClient;

  static FirebaseSimClient connect(String url,
      {required WebSocketChannelClientFactory webSocketChannelClientFactory}) {
    var client = webSocketChannelClientFactory.connect<String>(url);
    return FirebaseSimClient(client);
  }

  FirebaseSimClient(this.webSocketChannel) {
    rpcClient = json_rpc.Client(webSocketChannel!);
    init();
    // starting listening
    rpcClient.listen();
  }

  @override
  Future close() async {
    await _notificationController.close();
    await closeMixin();
  }

  Future<T?> sendRequest<T>(String method, [dynamic param]) async {
    T? t;
    if (debugFirebaseSimClient) {
      _log('request: $method $param');
    }
    try {
      t = await rpcClient.sendRequest(method, param) as T?;
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
}
