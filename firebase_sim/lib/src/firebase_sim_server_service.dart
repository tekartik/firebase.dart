import 'dart:core' hide Error;

import 'package:tekartik_common_utils/map_utils.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_server_app.dart';
import 'package:tekartik_rpc/rpc_server.dart';
import 'firebase_sim_server.dart';

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

//var firebaseSimServerExpando = Expando<FirebaseSimServerChannel>();

class FirebaseSimServerCoreService extends FirebaseSimServerServiceBase {
  static const serviceName = 'firebase_core';

  FirebaseSimServerCoreService() : super(serviceName);

  @override
  Future<Object?> onCall(
    RpcServerChannel channel,
    RpcMethodCall methodCall,
  ) async {
    var method = methodCall.method;
    var params = methodCall.arguments;
    var simServerChannel = simServer.channel(channel);

    switch (method) {
      case methodPing:
        var result = params;
        return result;

      case methodAdminInitializeApp:
        var result = simServerChannel.handleAdminInitializeApp(
          anyAsMap(params!),
        );
        var firebaseApp = simServerChannel.app!;
        await simServer.initForApp(firebaseApp);

        return result;
      case methodAdminGetServerAppHashCode:
        return simServerChannel.handleAdminGetServerAppHashCode();
      case methodAdminGetAppName:
        return simServerChannel.app!.name;
    }

    return super.onCall(channel, methodCall);
  }
}

class FirebaseSimServerChannel {
  // ignore: unused_field
  final RpcServerChannel _channel;
  final FirebaseSimServer _simServer;
  FirebaseSimServerProjectApp? projectApp;

  /// last result
  FirebaseApp? get app => projectApp?.app;
  final projectsByProjectId = <String, FirebaseSimServerProject>{};
  FirebaseSimServerChannel(this._simServer, this._channel);

  Map<String, Object?>? handleAdminInitializeApp(Map<String, dynamic> param) {
    var adminInitializeAppData = AdminInitializeAppData()..fromMap(param);

    var projectId = adminInitializeAppData.projectId!;

    var project = projectsByProjectId[projectId];
    if (project == null) {
      project = FirebaseSimServerProject(projectId);
      projectsByProjectId[projectId] = project;
    }
    var appName = adminInitializeAppData.name!;
    var projectApp = project.app(appName);

    /// Share the app if possible
    var options = AppOptions(projectId: projectId);
    projectApp.firebaseInitializeApp(_simServer.firebase, options);
    this.projectApp = projectApp;
    /*
    app = _simServer.getAppByProjectId(projectId);
    if (app == null) {
      app = _simServer.firebase.initializeApp(
        options: options,
        name: adminInitializeAppData.name,
      );
      _simServer.setProjectIdApp(projectId, app!);
    }*/

    return null;
  }

  // tmp
  Map<String, Object?>? handleAdminGetServerAppHashCode() {
    return {'hashCode': app!.hashCode};
  }
}
