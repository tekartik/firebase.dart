import 'dart:async';

import 'package:tekartik_firebase/firebase.dart';

// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';
import 'package:tekartik_web_socket/web_socket.dart';

class AppSim with FirebaseAppMixin {
  final FirebaseSim admin;
  bool deleted = false;
  final String _name;

  // when ready
  WebSocketChannel<String>? webSocketChannel;
  Completer<FirebaseSimClient>? readyCompleter;

  Future<FirebaseSimClient> get simClient async {
    if (readyCompleter == null) {
      readyCompleter = Completer();
      webSocketChannel = admin.clientFactory!.connect(admin.url);
      var simClient = FirebaseSimClient(webSocketChannel);
      var adminInitializeAppData = AdminInitializeAppData()
        ..projectId = options?.projectId
        ..name = name;
      try {
        await simClient.sendRequest(
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
  final AppOptions? options;

  // basic ping feature with console display
  Future ping() async {
    var simClient = await this.simClient;
    await simClient.sendRequest(methodPing);
  }

  // use the rpc
  Future<String?> getAppName() async {
    var simClient = await this.simClient;
    return await simClient.sendRequest(methodAdminGetAppName);
  }
}

String get _defaultAppName => firebaseAppNameDefault;

class FirebaseSim with FirebaseMixin {
  final WebSocketChannelClientFactory? clientFactory;
  final String url;

  FirebaseSim({this.clientFactory, String? url})
      : url = url ?? 'ws://localhost:$firebaseSimDefaultPort';

  final _apps = <String, AppSim>{};

  @override
  App initializeApp({AppOptions? options, String? name}) {
    name ??= _defaultAppName;
    var app = AppSim(this, options, name);
    _apps[name] = app;
    return app;
  }

  @override
  App app({String? name}) {
    name ??= _defaultAppName;
    return _apps[name]!;
  }
}
