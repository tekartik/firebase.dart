import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart'; // ignore: implementation_imports

String get _defaultAppName => firebaseAppNameDefault;
String get _defaultProjectId => 'local';

/// Local firebase implementation
class FirebaseLocal with FirebaseMixin {
  String? _localPath;

  /// Local path
  String? get localPath => _localPath;

  /// Create a local firebase
  FirebaseLocal({String? localPath}) {
    _localPath = localPath ?? join('.dart_tool', 'tekartik_firebase_local');
  }

  @override
  bool get isLocal => true;

  @override
  App initializeApp({FirebaseAppOptions? options, String? name}) {
    name ??= _defaultAppName;
    options ??= AppOptions(projectId: _defaultProjectId);

    var app = AppLocal(this, options, name);
    _apps[name] = FirebaseMixin.latestFirebaseInstanceOrNull = app;
    return app;
  }

  @override
  App app({String? name}) {
    name ??= _defaultAppName;
    for (var appName in _apps.keys) {
      if (appName == name) {
        return _apps[appName]!;
      }
    }
    return initializeApp(name: name);
  }

  /// List of apps
  final Map<String, AppLocal> _apps = {};
}

/// To deprecate
typedef AppLocal = FirebaseAppLocal;

/// Local app
class FirebaseAppLocal with FirebaseAppMixin {
  /// App path part
  static String appPathPart(String name) {
    return (name == _defaultAppName || name == '') ? '_default' : name;
  }

  /// Local firebase
  final FirebaseLocal firebaseLocal;

  @override
  Firebase get firebase => firebaseLocal;

  /// Local path
  String get localPath {
    var partPath = appPathPart(name);
    // If the name has more than 1 part, it is a path
    if (split(partPath).length == 1) {
      return join(firebaseLocal.localPath!, partPath);
    } else {
      return name;
    }
  }

  /// Path part
  String get pathPart => appPathPart(name);

  // Updated on init
  final AppOptions _options;

  @override
  AppOptions get options => _options;

  /// Deleted
  bool deleted = false;
  @override
  String name;

  /// Constructor
  FirebaseAppLocal(this.firebaseLocal, this._options, this.name);

  @override
  Future<void> delete() async {
    deleted = true;
    await closeServices();
  }
}

/// Helper to create a new app for test
FirebaseAppLocal newFirebaseAppLocal(
    {FirebaseAppOptions? options, String? localPath, String? name}) {
  var firebase = FirebaseLocal(localPath: localPath);
  var app =
      firebase.initializeApp(name: name, options: options) as FirebaseAppLocal;
  return app;
}
