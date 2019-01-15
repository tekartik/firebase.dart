import 'dart:async';

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_web_socket/web_socket.dart';

class AppSim implements App {
  final FirebaseSim admin;
  bool deleted = false;
  String _name;

  // when ready
  WebSocketChannel<String> webSocketChannel;
  Completer<FirebaseSimClient> readyCompleter;

  Future<FirebaseSimClient> get simClient async {
    if (readyCompleter == null) {
      readyCompleter = Completer();
      webSocketChannel = admin.clientFactory.connect(admin.url);
      var simClient = FirebaseSimClient(webSocketChannel);
      var adminInitializeAppData = AdminInitializeAppData()
        ..projectId = options?.projectId
        ..name = name;
      try {
        await simClient.sendRequest(
            methodAdminInitializeApp, adminInitializeAppData.toMap());
        readyCompleter.complete(simClient);
      } catch (e) {
        readyCompleter.completeError(e);
      }
    }
    return readyCompleter.future;
  }

  AppSim(this.admin, this.options, this._name) {
    _name ??= firebaseAppNameDefault;
  }

  @override
  Future delete() async {
    if (!deleted) {
      deleted = true;
      // await _firestore?.close();
    }
  }

  @override
  String get name => _name;

  @override
  final AppOptions options;

  // basic ping feature with console display
  Future ping() async {
    var simClient = await this.simClient;
    await simClient.sendRequest(methodPing);
  }

  // use the rpc
  Future<String> getAppName() async {
    var simClient = await this.simClient;
    return await simClient.sendRequest(methodAdminGetAppName);
  }
}

class FirebaseSim implements Firebase {
  final WebSocketChannelClientFactory clientFactory;
  final String url;

  FirebaseSim({this.clientFactory, this.url});

  @override
  App initializeApp({AppOptions options, String name}) {
    return AppSim(this, options, name);
  }

  @override
  Future<App> initializeAppAsync({AppOptions options, String name}) async {
    return initializeApp(options: options, name: name);
  }
}
