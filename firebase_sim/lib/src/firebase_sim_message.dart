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

class AdminInitializeAppResponseData extends BaseData {
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

typedef AdminAppGetNameRequestData = AdminAppBaseData;
typedef AdminAppCloseRequestData = AdminAppBaseData;

class AdminAppGetNameResponseData extends BaseData {
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

void firebaseSimInitCvBuilders() {
  cvAddConstructors([CvFirebaseSimAppBaseData.new]);
}

/// Base data for app related requests
class CvFirebaseSimAppBaseData extends CvModelBase {
  final appId = CvField<int>('appId');
  @override
  CvFields get fields => [appId];
}

class AdminAppBaseData extends BaseData {
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
