import 'dart:async';

import 'package:firebase_core/firebase_core.dart' as flutter;
import 'package:tekartik_firebase/firebase.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';

AppOptions _fromNativeOption(flutter.FirebaseOptions fbOptions) {
  var options = AppOptions(
      apiKey: fbOptions.apiKey,
      storageBucket: fbOptions.storageBucket,
      projectId: fbOptions.projectId,
      databaseURL: fbOptions.databaseURL);
  return options;
}

class FirebaseFlutter implements FirebaseAsync, Firebase {
  @override
  Future<App> initializeAppAsync({AppOptions options, String name}) async {
    flutter.FirebaseApp nativeApp;
    var isDefault = false;
    if (options != null) {
      // If empty (checking only projectId)
      // clone the existing options
      if (options.projectId == null) {
        nativeApp = await flutter.Firebase.initializeApp(name: name);
      } else {
        throw 'not supported yet';
      }
    } else {
      isDefault = true;
      nativeApp = await flutter.Firebase.initializeApp(name: name);
    }
    options = _fromNativeOption(nativeApp.options);

    return AppFlutter(
        nativeInstance: nativeApp, options: options, isDefault: isDefault);
  }

  @override
  App initializeApp({AppOptions options, String name}) {
    if (options == null && name == null) {
      // TODO 2020-08-26 if this fail, consider calling async method only
      var nativeApp = flutter.Firebase.app();
      options = _fromNativeOption(nativeApp.options);
      return AppFlutter(
          nativeInstance: nativeApp, options: options, isDefault: true);
    } else {
      throw 'not supported, use async method';
    }
  }

  @override
  App app({String name}) {
    if (name == null) {
      var nativeApp = flutter.Firebase.app();
      return AppFlutter(
          nativeInstance: nativeApp,
          options: _fromNativeOption(nativeApp.options),
          isDefault: true);
    }
    throw UnsupportedError(
        'Flutter has only a single default app instantiated');
  }

  @override
  Future<App> appAsync({String name}) async => initializeAppAsync(name: name);
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
