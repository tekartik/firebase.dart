import 'package:tekartik_common_utils/string_utils.dart';

/// This is the new type, App will be deprecated in the future
typedef AppOptions = FirebaseAppOptions;

/// Firebase app options
class FirebaseAppOptions {
  /// Api key
  String? apiKey;

  /// Auth domain
  String? authDomain;

  /// Database url
  String? databaseURL;

  /// Project id
  String? projectId;

  /// Storage bucket
  String? storageBucket;

  /// Messaging sender id
  String? messagingSenderId;

  /// Measurement id
  String? measurementId;

  /// App id
  String? appId;

  /// Constructor
  FirebaseAppOptions(
      {this.apiKey,
      this.authDomain,
      this.databaseURL,
      this.projectId,
      this.storageBucket,
      this.messagingSenderId,
      this.appId,
      this.measurementId});

  /// Create from map
  factory FirebaseAppOptions.fromMap(Map<String, Object?> map) =>
      FirebaseAppOptionsFromMap(map);

  /// To debug map
  Map<String, Object?> toDebugMap() {
    return {
      if (apiKey != null) 'apiKey': apiKey!.obfuscate(),
      'projectId': projectId
    };
  }

  @override
  String toString() => toDebugMap().toString();
}

/// Firebase app options from map
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

  /// Constructor for map
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
}

/// Firebase app options mixin
mixin FirebaseAppOptionsMixin implements FirebaseAppOptions {
  @override
  Map<String, Object?> toDebugMap() {
    return {
      if (apiKey != null) 'apiKey': apiKey!.obfuscate(),
      'projectId': projectId
    };
  }

  @override
  String? get apiKey => throw UnimplementedError();

  @override
  String? get appId => throw UnimplementedError();

  @override
  String? get authDomain => throw UnimplementedError();

  @override
  String? get databaseURL => throw UnimplementedError();

  @override
  String? get measurementId => throw UnimplementedError();

  @override
  String? get messagingSenderId => throw UnimplementedError();

  @override
  String? get projectId => throw UnimplementedError();

  @override
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
