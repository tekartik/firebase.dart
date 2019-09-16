import 'dart:async';

import 'package:firebase_core/firebase_core.dart' as flutter;
import 'package:tekartik_firebase/firebase.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';

class FirebaseFlutter implements FirebaseAsync, Firebase {
  @override
  Future<App> initializeAppAsync({AppOptions options, String name}) async {
    flutter.FirebaseApp nativeApp;
    bool isDefault = false;
    if (options != null) {
      // If empty (checking only projectId)
      // clone the existing options
      if (options.projectId == null) {
        flutter.FirebaseOptions fbOptions =
            await flutter.FirebaseApp.instance.options;
        nativeApp =
            await flutter.FirebaseApp.configure(name: name, options: fbOptions);
      } else {
        throw 'not supported yet';
      }
    } else {
      isDefault = true;
      nativeApp = flutter.FirebaseApp.instance;
    }

    return AppFlutter(
        nativeInstance: nativeApp, options: options, isDefault: isDefault);
  }

  @override
  App initializeApp({AppOptions options, String name}) {
    if (options == null && name == null) {
      var nativeApp = flutter.FirebaseApp.instance;
      return AppFlutter(
          nativeInstance: nativeApp, options: options, isDefault: true);
    } else {
      throw 'not supported, use async method';
    }
  }
}

class AppFlutter with FirebaseAppMixin {
  final bool isDefault;
  @override
  final AppOptions options;
  final flutter.FirebaseApp nativeInstance;

  AppFlutter({this.nativeInstance, this.options, this.isDefault});

  @override
  Future delete() async {
    await closeServices();
    // delete is not supported, simply ignore
    // throw 'not supported';
  }

  @override
  String get name => nativeInstance.name;

  @override
  String toString() => 'AppFlutter($name)';
}

FirebaseFlutter _firebaseFlutter;

FirebaseFlutter get firebaseFlutter => _firebaseFlutter ??= FirebaseFlutter();
