import 'package:cv/cv.dart';

/// Subscription id
const paramSubscriptionId = 'subscriptionId';

/// App id
const paramAppId = 'appId';

/// Done
const paramDone = 'done'; // bool
/// Ping method
const methodPing = 'ping'; // from client or server

/// InitializeApp method
const methodAdminInitializeApp = 'admin/initializeApp';

/// Close method
const methodAdminCloseApp = 'admin/closeApp';

/// GetAppName method
const methodAdminGetAppName = 'admin/getAppName';

/// GetServerHashCode method
const methodAdminGetAppDelegateName = 'admin/getAppDelegateName';

/// Base data class.
class BaseData {
  /// Initialize from map.
  void fromMap(Map map) {}

  /// Convert to map.
  Model toMap() {
    var map = <String, dynamic>{};
    return map;
  }

  @override
  String toString() => toMap().toString();
}

/// Admin initialize app data.
class AdminInitializeAppData extends BaseData {
  /// Project ID.
  String? projectId;

  /// App name.
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

/// Admin initialize app response data.
class AdminInitializeAppResponseData extends BaseData {
  /// App ID.
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

/// Admin app get name request data.
typedef AdminAppGetNameRequestData = AdminAppBaseData;

/// Admin app close request data.
typedef AdminAppCloseRequestData = AdminAppBaseData;

/// Admin app get name response data.
class AdminAppGetNameResponseData extends BaseData {
  /// App name.
  String? name;

  @override
  void fromMap(Map map) {
    name = map['name'] as String?;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = {'name': name};
    return map;
  }
}

/// Initialize CV builders.
void firebaseSimInitCvBuilders() {
  cvAddConstructors([CvFirebaseSimAppBaseData.new]);
}

/// Base data for app related requests
class CvFirebaseSimAppBaseData extends CvModelBase {
  /// App ID.
  final appId = CvField<int>('appId');
  @override
  CvFields get fields => [appId];
}

/// Admin app base data.
class AdminAppBaseData extends BaseData {
  /// App ID.
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
