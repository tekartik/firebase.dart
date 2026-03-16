import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart'; // ignore: implementation_imports

String get _defaultAppName => firebaseAppNameDefault;
String get _defaultProjectId => 'local';

/// Local firebase implementation
class FirebaseLocal with FirebaseWithAppsMixin, FirebaseMixin {
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
  FirebaseAppLocal initializeApp({FirebaseAppOptions? options, String? name}) {
    name ??= _defaultAppName;
    // Not valid for local...
    checkAppNameUninitialized(name);
    options ??= AppOptions(projectId: _defaultProjectId);

    var app = FirebaseAppLocal(this, options, name);
    return addApp(app);
  }
}

/// To deprecate
typedef AppLocal = FirebaseAppLocal;

/// Local app
class FirebaseAppLocal with FirebaseAppMixin {
  /// App path part
  @Deprecated('do not use')
  static String appPathPart(String name) {
    return (name == _defaultAppName || name == '') ? '_default' : name;
  }

  /// Local firebase
  final FirebaseLocal firebaseLocal;

  @override
  Firebase get firebase => firebaseLocal;

  /// Local path
  String get localPath {
    return join(firebaseLocal.localPath!, options.projectId!);
  }

  /// Path part, using the projectId
  @Deprecated('do not use')
  String get pathPart => options.projectId!;

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
    firebaseLocal.uninitializeApp(this);
  }
}

/// Helper to create a new app for test
FirebaseAppLocal newFirebaseAppLocal({
  FirebaseAppOptions? options,
  String? localPath,
  String? name,
}) {
  var firebase = FirebaseLocal(localPath: localPath);
  var app = firebase.initializeApp(name: name, options: options);
  return app;
}
