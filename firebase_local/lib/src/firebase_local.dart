import 'dart:async';

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';

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
    return AppLocal(this, options, name ?? _defaultAppName);
  }

  @override
  App app({String name}) {
    name ??= _defaultAppName;
    for (var app in apps.keys) {
      if (app.name == name) {
        return app;
      }
    }
    return null;
  }

  final Map<App, AppLocal> apps = {};
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

  @override
  final AppOptions options;

  bool deleted = false;
  @override
  String name;

  AppLocal(this.firebaseLocal, this.options, this.name);

  @override
  Future<void> delete() async {
    deleted = true;
    await closeServices();
  }
}
