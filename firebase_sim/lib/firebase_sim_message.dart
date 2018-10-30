const methodPing = 'ping'; // from client or server

const methodAdminInitializeApp = 'admin/initializeApp';
const methodAdminGetAppName = 'admin/getAppName';

class RawData {
  fromMap(Map<String, dynamic> map) {}

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    return map;
  }

  toString() => toMap().toString();
}

class BaseData {
  fromMap(Map<String, dynamic> map) {}

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    return map;
  }

  toString() => toMap().toString();
}

class AdminInitializeAppData extends BaseData {
  String projectId;
  String name;

  fromMap(Map<String, dynamic> map) {
    projectId = map['projectId'] as String;
    name = map['name'] as String;
  }

  Map<String, dynamic> toMap() {
    var map = {'projectId': projectId, 'name': name};
    return map;
  }
}

class FirebaseInitializeAppResponseData extends BaseData {
  int appId;

  fromMap(Map<String, dynamic> map) {
    appId = map['appId'] as int;
  }

  Map<String, dynamic> toMap() {
    var map = {
      'appId': appId,
    };
    return map;
  }
}
