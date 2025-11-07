import 'dart:core' hide Error;

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/foundation/constants.dart';
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

  FutureOr<Object?> onServiceCall(
    RpcServerChannel channel,
    RpcMethodCall methodCall,
  ) async {
    throw RpcException(
      'unsupported',
      '$name: onServiceCall($methodCall) not supported',
    );
  }

  /// Default implementation that routes to app or service call
  @override
  FutureOr<Object?> onCall(
    RpcServerChannel channel,
    RpcMethodCall methodCall,
  ) async {
    var params = methodCall.arguments;
    var simServerChannel = simServer.channel(channel);
    if (params is Map) {
      var appId = params[paramAppId];
      if (appId is int) {
        var app = simServerChannel.appById(appId);
        return onAppCall(app, channel, methodCall);
      }
    }
    return onServiceCall(channel, methodCall);
  }

  FutureOr<Object?> onAppCall(
    FirebaseSimServerProjectApp projectApp,
    RpcServerChannel channel,
    RpcMethodCall methodCall,
  ) async {
    throw RpcException(
      'unsupported',
      '$name: onAppCall($methodCall) not supported',
    );
  }

  FirebaseSimServerServiceBase(super.name);
}

//var firebaseSimServerExpando = Expando<FirebaseSimServerChannel>();

class FirebaseSimServerCoreService extends FirebaseSimServerServiceBase {
  static const serviceName = 'firebase_core';

  FirebaseSimServerCoreService() : super(serviceName);

  @override
  Future<Object?> onServiceCall(
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
        var projectApp = await simServerChannel.handleAdminInitializeApp(
          anyAsMap(params!),
        );
        var firebaseApp = projectApp.app!;
        await simServer.initForApp(firebaseApp);

        return (AdminInitializeAppResponseData()..appId = projectApp.appId)
            .toMap();
    }

    return super.onServiceCall(channel, methodCall);
  }

  @override
  Future<Object?> onAppCall(
    FirebaseSimServerProjectApp projectApp,
    RpcServerChannel channel,
    RpcMethodCall methodCall,
  ) async {
    var method = methodCall.method;
    var params = methodCall.arguments;
    var simServerChannel = simServer.channel(channel);

    switch (method) {
      case methodAdminCloseApp:
        await simServerChannel.handleAppClose(anyAsMap(params!));
        return null;

      case methodAdminGetAppDelegateName:
        return await simServerChannel.handleAppGetDelegateName(
          anyAsMap(params!),
        );

      case methodAdminGetAppName:
        return await simServerChannel.handleAppGetName(anyAsMap(params!));
    }

    return super.onAppCall(projectApp, channel, methodCall);
  }
}

class FirebaseSimServerChannel {
  // ignore: unused_field
  final RpcServerChannel _channel;
  final FirebaseSimServer _simServer;

  FirebaseSimServerProjectApp appById(int appId) {
    var app = _appsByAppId[appId];
    if (app == null) {
      throw StateError('App with id $appId not found');
    }
    return app;
  }

  /// Apps by appId
  final _appsByAppId = <int, FirebaseSimServerProjectApp>{};
  // FirebaseSimServerProjectApp? projectApp;

  /// last result
  @Deprecated('use appsByAppId')
  FirebaseApp? get app {
    if (kDebugMode) {
      throw UnimplementedError(
        'FirebaseSimServerChannel.app is deprecated, use appsByAppId',
      );
    }
    return _appsByAppId.values.firstOrNull?.app;
  }

  final projectsByProjectId = <String, FirebaseSimServerProject>{};
  FirebaseSimServerChannel(this._simServer, this._channel);

  Future<Map<String, Object?>?> handleAppGetName(
    Map<String, dynamic> param,
  ) async {
    var getNameData = AdminAppGetNameRequestData()..fromMap(param);
    var appId = getNameData.appId!;
    var projectApp = _appsByAppId[appId];
    if (projectApp != null) {
      return (AdminAppGetNameResponseData()..name = projectApp.appName).toMap();
    }
    throw StateError('GetName App with id $appId not found');
  }

  Future<Map<String, Object?>?> handleAppGetDelegateName(
    Map<String, dynamic> param,
  ) async {
    var getNameData = AdminAppGetNameRequestData()..fromMap(param);
    var appId = getNameData.appId!;
    var projectApp = _appsByAppId[appId];
    if (projectApp != null) {
      return (AdminAppGetNameResponseData()
            ..name = projectApp.project.appDelegate.appName)
          .toMap();
    }
    return null;
  }

  Future<void> handleAppClose(Map<String, dynamic> param) async {
    var getNameData = AdminAppCloseRequestData()..fromMap(param);
    var appId = getNameData.appId!;
    var projectApp = _appsByAppId[appId];

    /// Remove the app from the map
    _appsByAppId.remove(appId);
    await projectApp?.firebaseDeleteApp();
  }

  Future<FirebaseSimServerProjectApp> handleAdminInitializeApp(
    Map<String, dynamic> param,
  ) async {
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
    await projectApp.firebaseInitializeApp(_simServer.firebase, options);
    _appsByAppId[projectApp.appId] = projectApp;
    //this.projectApp = projectApp;
    /*
    app = _simServer.getAppByProjectId(projectId);
    if (app == null) {
      app = _simServer.firebase.initializeApp(
        options: options,
        name: adminInitializeAppData.name,
      );
      _simServer.setProjectIdApp(projectId, app!);
    }*/
    return projectApp;
  }
}
