import 'dart:async';

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_firebase_sim/rpc_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server.dart';
import 'package:tekartik_web_socket/web_socket.dart';

export 'package:tekartik_firebase_sim/src/firebase_sim_client.dart'
    show FirebaseSim;
import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;

const requestTimeoutDuration = Duration(seconds: 15);

class FirebaseSimClient extends Object with FirebaseSimMixin {
  var _notificationController = StreamController<Notification>.broadcast();

  Stream<Notification> get notificationStream => _notificationController.stream;
  final WebSocketChannel<String> webSocketChannel;
  json_rpc.Client rpcClient;

  static FirebaseSimClient connect(String url,
      {WebSocketChannelClientFactory webSocketChannelClientFactory}) {
    var client = webSocketChannelClientFactory.connect<String>(url);
    return FirebaseSimClient(client);
  }

  FirebaseSimClient(this.webSocketChannel) {
    rpcClient = json_rpc.Client(webSocketChannel);
    init();
    // starting listening
    rpcClient.listen();
  }

  @override
  close() async {
    await _notificationController.close();
    await closeMixin();
  }

  Future<T> sendRequest<T>(String method, [dynamic param]) async {
    T t;
    try {
      t = await rpcClient.sendRequest(method, param) as T;
    } on json_rpc.RpcException catch (e) {
      // devPrint('ERROR ${e.runtimeType} $e ${e.message} ${e.data}');
      if (isDebug) {
        print(e);
        print('sending $method $param');
      }
      throw e.message;
    }
    return t;
  }
}
