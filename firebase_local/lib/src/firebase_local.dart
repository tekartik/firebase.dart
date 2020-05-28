import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart'; // ignore: implementation_imports

String get _defaultAppName => firebaseAppNameDefault;

class FirebaseLocal with FirebaseMixin {
  String _localPath;

  String get localPath => _localPath;

  FirebaseLocal({String localPath}) {
    _localPath = localPath ?? join('.dart_tool', 'tekartik_firebase_local');
  }

  @override
  App initializeApp({AppOptions options, String name}) {
    name ??= _defaultAppName;
    options ??= AppOptions();

    var app = AppLocal(this, options, name);
    apps[name] = app;
    return app;
  }

  @override
  App app({String name}) {
    name ??= _defaultAppName;
    for (var appName in apps.keys) {
      if (appName == name) {
        return apps[appName];
      }
    }
    return initializeApp(name: name);
  }

  final Map<String, AppLocal> apps = {};
}

class AppLocal with FirebaseAppMixin {
  static String appPathPart(String name) {
    return (name == _defaultAppName || name == null || name == '')
        ? '_default'
        : name;
  }

  final FirebaseLocal firebaseLocal;

  String get localPath {
    var partPath = appPathPart(name);
    // If the name has more than 1 part, it is a path
    if (split(partPath).length == 1) {
      return join(firebaseLocal.localPath, partPath);
    } else {
      return name;
    }
  }

  String get pathPart => appPathPart(name);

  // Updated on init
  AppOptions _options;

  @override
  AppOptions get options => _options;

  bool deleted = false;
  @override
  String name;

  AppLocal(this.firebaseLocal, _options, this.name) {
    // never null
    _options ??= AppOptions();
  }

  @override
  Future<void> delete() async {
    deleted = true;
    await closeServices();
  }
}
