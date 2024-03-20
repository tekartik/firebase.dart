import 'utils.dart';

/// This is the new type, App will be deprecated in the future
typedef FirebaseAppOptions = AppOptions;

class AppOptions {
  String? apiKey;
  String? authDomain;
  String? databaseURL;
  String? projectId;
  String? storageBucket;
  String? messagingSenderId;
  String? measurementId;
  String? appId;

  AppOptions(
      {this.apiKey,
      this.authDomain,
      this.databaseURL,
      this.projectId,
      this.storageBucket,
      this.messagingSenderId,
      this.appId,
      this.measurementId});

  factory AppOptions.fromMap(Map<String, Object?> map) =>
      FirebaseAppOptionsFromMap(map);

  Map<String, Object?> toDebugMap() {
    return {'apiKey': obfuscate(apiKey), projectId!: projectId};
  }

  @override
  String toString() => toDebugMap().toString();
}

class FirebaseAppOptionsFromMap
    with FirebaseAppOptionsMixin
    implements FirebaseAppOptions {
  @override
  String? apiKey;
  @override
  String? authDomain;
  @override
  String? databaseURL;
  @override
  String? projectId;
  @override
  String? storageBucket;
  @override
  String? messagingSenderId;
  @override
  String? measurementId;
  @override
  String? appId;

  FirebaseAppOptionsFromMap(Map<String, Object?> map) {
    apiKey = map['apiKey']?.toString();
    authDomain = map['authDomain']?.toString();
    databaseURL = map['databaseURL']?.toString();
    projectId = map['projectId']?.toString();
    storageBucket = map['storageBucket']?.toString();
    messagingSenderId = map['messagingSenderId']?.toString();
    measurementId = map['measurementId']?.toString();
    appId = map['appId']?.toString();
  }

  @override
  Map<String, Object?> toDebugMap() {
    return {'apiKey': obfuscate(apiKey), projectId!: projectId};
  }
}

mixin FirebaseAppOptionsMixin implements FirebaseAppOptions {
  @override
  Map<String, Object?> toDebugMap() {
    return {'apiKey': obfuscate(apiKey), projectId!: projectId};
  }

  @override
  // TODO: implement apiKey
  String? get apiKey => throw UnimplementedError();

  @override
  // TODO: implement appId
  String? get appId => throw UnimplementedError();

  @override
  // TODO: implement authDomain
  String? get authDomain => throw UnimplementedError();

  @override
  // TODO: implement databaseURL
  String? get databaseURL => throw UnimplementedError();

  @override
  // TODO: implement measurementId
  String? get measurementId => throw UnimplementedError();

  @override
  // TODO: implement messagingSenderId
  String? get messagingSenderId => throw UnimplementedError();

  @override
  // TODO: implement projectId
  String? get projectId => throw UnimplementedError();

  @override
  // TODO: implement storageBucket
  String? get storageBucket => throw UnimplementedError();

  @override
  set apiKey(String? apiKey) {
    throw UnsupportedError('read only');
  }

  @override
  set appId(String? appId) {
    throw UnsupportedError('read only');
  }

  @override
  set authDomain(String? authDomain) {
    throw UnsupportedError('read only');
  }

  @override
  set databaseURL(String? databaseURL) {
    throw UnsupportedError('read only');
  }

  @override
  set measurementId(String? measurementId) {
    throw UnsupportedError('read only');
  }

  @override
  set messagingSenderId(String? messagingSenderId) {
    throw UnsupportedError('read only');
  }

  @override
  set projectId(String? projectId) {
    throw UnsupportedError('read only');
  }

  @override
  set storageBucket(String? storageBucket) {
    throw UnsupportedError('read only');
  }
}
