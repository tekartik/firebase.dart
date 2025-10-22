import 'dart:core' hide Error;

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firebase.dart';

import 'firebase_sim_server_service.dart';

/// Default mixin for FirebaseSimPlugin
mixin FirebaseSimPluginDefaultMixin implements FirebaseSimPlugin {
  /// Sim service init for app
  @override
  FutureOr<void> initForApp(FirebaseApp app) {
    // Do nothing
  }
}

abstract class FirebaseSimPlugin {
  FirebaseSimServerService get simService;
  FutureOr<void> initForApp(FirebaseApp app);
  //FirebaseSimPluginServer register(App app, json_rpc.Server rpcServer);
}
