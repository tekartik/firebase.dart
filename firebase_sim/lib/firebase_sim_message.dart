/// Ping method
const methodPing = 'ping'; // from client or server

/// InitializeApp method
const methodAdminInitializeApp = 'admin/initializeApp';

/// GetAppName method
const methodAdminGetAppName = 'admin/getAppName';

class RawData {
  void fromMap(Map<String, dynamic> map) {}

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    return map;
  }

  @override
  String toString() => toMap().toString();
}

class BaseData {
  void fromMap(Map<String, dynamic> map) {}

  Map<String, dynamic> toMap() {
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
  void fromMap(Map<String, dynamic> map) {
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
  void fromMap(Map<String, dynamic> map) {
    appId = map['appId'] as int?;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = {'appId': appId};
    return map;
  }
}
