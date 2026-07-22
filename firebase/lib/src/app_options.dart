import 'package:tekartik_common_utils/string_utils.dart';

/// Alias for [FirebaseAppOptions], kept for backward compatibility.
///
/// Prefer [FirebaseAppOptions] directly; this typedef may be deprecated in
/// the future.
typedef AppOptions = FirebaseAppOptions;

/// The configuration a [FirebaseApp] is initialized with (API key, project
/// id, ...).
///
/// All fields are mutable and nullable: a field left `null` means the
/// corresponding value was not configured, either because it does not apply
/// to the current platform/services or because it can be resolved another
/// way (e.g. from the runtime environment).
class FirebaseAppOptions {
  /// The Firebase Web API key for the project, if configured.
  String? apiKey;

  /// The domain used for Firebase Authentication redirects (e.g.
  /// `<project>.firebaseapp.com`), if configured.
  String? authDomain;

  /// The Realtime Database URL, if configured.
  String? databaseURL;

  /// The Firebase project id.
  String? projectId;

  /// The default Cloud Storage bucket name, if configured.
  String? storageBucket;

  /// The Firebase Cloud Messaging sender id, if configured.
  String? messagingSenderId;

  /// The Google Analytics measurement id, if configured.
  String? measurementId;

  /// The Firebase application id, if configured.
  String? appId;

  /// Creates Firebase app options.
  ///
  /// All parameters are optional and set the field of the same name (see
  /// [apiKey], [authDomain], [databaseURL], [projectId], [storageBucket],
  /// [messagingSenderId], [appId] and [measurementId]); omitted fields
  /// remain `null` and can still be set afterwards since they are mutable.
  FirebaseAppOptions({
    this.apiKey,
    this.authDomain,
    this.databaseURL,
    this.projectId,
    this.storageBucket,
    this.messagingSenderId,
    this.appId,
    this.measurementId,
  });

  /// Creates [FirebaseAppOptions] from a decoded, JSON-like [map].
  ///
  /// [map] is expected to hold values under the same keys as this class'
  /// fields (e.g. `'apiKey'`, `'projectId'`, ...); each value is converted
  /// with [Object.toString]. Keys that are absent or `null` leave the
  /// corresponding field `null`.
  ///
  /// Returns a new, mutable [FirebaseAppOptions] instance.
  factory FirebaseAppOptions.fromMap(Map<String, Object?> map) =>
      FirebaseAppOptionsFromMap(map);

  /// A small map suitable for logging or debug output.
  ///
  /// Only [projectId] and an obfuscated version of [apiKey] (when set) are
  /// included; other fields are omitted to avoid leaking sensitive values.
  Map<String, Object?> toDebugMap() {
    return {
      if (apiKey != null) 'apiKey': apiKey!.obfuscate(),
      'projectId': projectId,
    };
  }

  @override
  String toString() => toDebugMap().toString();
}

/// Firebase app options from map.
/// @internal
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

/// Mixin providing default [FirebaseAppOptions] member implementations.
///
/// Every getter throws [UnimplementedError] and every setter throws
/// [UnsupportedError] by default. Concrete implementations are expected to
/// override the getters they can supply a value for (typically to expose
/// read-only options coming from another source), leaving the setters
/// throwing when the options are not meant to be mutated after creation.
mixin FirebaseAppOptionsMixin implements FirebaseAppOptions {
  /// A small map suitable for logging or debug output. See
  /// [FirebaseAppOptions.toDebugMap].
  @override
  Map<String, Object?> toDebugMap() {
    return {
      if (apiKey != null) 'apiKey': apiKey!.obfuscate(),
      'projectId': projectId,
    };
  }

  /// See [FirebaseAppOptions.apiKey]. Throws [UnimplementedError] unless
  /// overridden.
  @override
  String? get apiKey => throw UnimplementedError();

  /// See [FirebaseAppOptions.appId]. Throws [UnimplementedError] unless
  /// overridden.
  @override
  String? get appId => throw UnimplementedError();

  /// See [FirebaseAppOptions.authDomain]. Throws [UnimplementedError] unless
  /// overridden.
  @override
  String? get authDomain => throw UnimplementedError();

  /// See [FirebaseAppOptions.databaseURL]. Throws [UnimplementedError]
  /// unless overridden.
  @override
  String? get databaseURL => throw UnimplementedError();

  /// See [FirebaseAppOptions.measurementId]. Throws [UnimplementedError]
  /// unless overridden.
  @override
  String? get measurementId => throw UnimplementedError();

  /// See [FirebaseAppOptions.messagingSenderId]. Throws [UnimplementedError]
  /// unless overridden.
  @override
  String? get messagingSenderId => throw UnimplementedError();

  /// See [FirebaseAppOptions.projectId]. Throws [UnimplementedError] unless
  /// overridden.
  @override
  String? get projectId => throw UnimplementedError();

  /// See [FirebaseAppOptions.storageBucket]. Throws [UnimplementedError]
  /// unless overridden.
  @override
  String? get storageBucket => throw UnimplementedError();

  /// Sets [FirebaseAppOptions.apiKey]. Throws [UnsupportedError] by default;
  /// override to support mutation.
  @override
  set apiKey(String? apiKey) {
    throw UnsupportedError('read only');
  }

  /// Sets [FirebaseAppOptions.appId]. Throws [UnsupportedError] by default;
  /// override to support mutation.
  @override
  set appId(String? appId) {
    throw UnsupportedError('read only');
  }

  /// Sets [FirebaseAppOptions.authDomain]. Throws [UnsupportedError] by
  /// default; override to support mutation.
  @override
  set authDomain(String? authDomain) {
    throw UnsupportedError('read only');
  }

  /// Sets [FirebaseAppOptions.databaseURL]. Throws [UnsupportedError] by
  /// default; override to support mutation.
  @override
  set databaseURL(String? databaseURL) {
    throw UnsupportedError('read only');
  }

  /// Sets [FirebaseAppOptions.measurementId]. Throws [UnsupportedError] by
  /// default; override to support mutation.
  @override
  set measurementId(String? measurementId) {
    throw UnsupportedError('read only');
  }

  /// Sets [FirebaseAppOptions.messagingSenderId]. Throws [UnsupportedError]
  /// by default; override to support mutation.
  @override
  set messagingSenderId(String? messagingSenderId) {
    throw UnsupportedError('read only');
  }

  /// Sets [FirebaseAppOptions.projectId]. Throws [UnsupportedError] by
  /// default; override to support mutation.
  @override
  set projectId(String? projectId) {
    throw UnsupportedError('read only');
  }

  /// Sets [FirebaseAppOptions.storageBucket]. Throws [UnsupportedError] by
  /// default; override to support mutation.
  @override
  set storageBucket(String? storageBucket) {
    throw UnsupportedError('read only');
  }
}
