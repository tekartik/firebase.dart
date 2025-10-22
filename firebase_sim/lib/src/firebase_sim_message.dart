import 'package:cv/cv.dart';

/// Subscription id
const paramSubscriptionId = 'subscriptionId';

/// Done
const paramDone = 'done'; // bool
/// Ping method
const methodPing = 'ping'; // from client or server

/// InitializeApp method
const methodAdminInitializeApp = 'admin/initializeApp';

/// Close method (unused for now)
const methodAdminCloseApp = 'admin/closeApp';

/// GetAppName method
const methodAdminGetAppName = 'admin/getAppName';

/// GetServerHashCode method
const methodAdminGetServerAppHashCode = 'admin/getServerHashCode';

class BaseData {
  void fromMap(Map map) {}

  Model toMap() {
    var map = <String, dynamic>{};
    return map;
  }

  @override
  String toString() => toMap().toString();
}

class AdminInitializeAppData extends BaseData {
  String? projectId;
  String? name;

  @override
  void fromMap(Map map) {
    projectId = map['projectId'] as String?;
    name = map['name'] as String?;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = {'projectId': projectId, 'name': name};
    return map;
  }
}

class FirebaseInitializeAppResponseData extends BaseData {
  int? appId;

  @override
  void fromMap(Map map) {
    appId = map['appId'] as int?;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = {'appId': appId};
    return map;
  }
}
