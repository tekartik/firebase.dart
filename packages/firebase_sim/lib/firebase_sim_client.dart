import 'dart:async';

import 'package:tekartik_firebase_sim/rpc_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server.dart';
import 'package:tekartik_web_socket/web_socket.dart';

export 'src/firebase_sim_client.dart' show FirebaseSimClientAdmin;

const requestTimeoutDuration = const Duration(seconds: 15);

class _Request {
  final Request request;
  dynamic response;
  final completer = new Completer();

  _Request(this.request);
}

class FirebaseSimClient extends Object with FirebaseSimMixin {
  var _notificationController = new StreamController<Notification>.broadcast();

  Stream<Notification> get notificationStream => _notificationController.stream;
  int _lastRequestId = 0;
  final WebSocketChannel<String> webSocketChannel;
  final Map<int, _Request> _currentRequests = {};

  FirebaseSimClient(this.webSocketChannel) {
    init();
  }

  @override
  close() async {
    await _notificationController.close();
    await closeMixin();
  }

  Request newRequest(String method, [data]) {
    return new Request(++_lastRequestId, method, data);
  }

  Future< /*Response | ErrorResponse*/ dynamic> sendRequest(
      Request request) async {
    int id = request.id as int;
    _Request internalRequest = new _Request(request);
    try {
      _currentRequests[id] = internalRequest;
      sendMessage(request);
      await internalRequest.completer.future.timeout(requestTimeoutDuration);
      return internalRequest.response;
    } finally {
      _currentRequests.remove(id);
    }
  }

  @override
  void handleMessage(Message message) {
    if (message is Response || message is ErrorResponse) {
      handleResponse(message);
    } else if (message is Notification) {
      handleNotification(message);
    }
  }

  void handleResponse(/*Response | ErrorResponse*/ Message response) {
    int id;
    if (response is Response) {
      id = response.id as int;
    } else {
      id = (response as ErrorResponse).id as int;
    }
    _Request internalRequest = _currentRequests[id];
    if (internalRequest != null) {
      internalRequest.response = response;
      internalRequest.completer.complete(response);
    } else {
      print('unhandled response ${response}');
    }
  }

  void handleNotification(Notification notification) {
    _notificationController.add(notification);
  }
}
