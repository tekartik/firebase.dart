import 'dart:async';

import 'package:tekartik_firebase/src/utils.dart';

export 'package:tekartik_firebase/src/firebase.dart'
    show firebaseAppNameDefault;

/// Async interface, needed for flutter.
abstract class FirebaseAsync {
  /// Initialize the app with the given options.
  Future<App> initializeAppAsync({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  Future<App> appAsync({String? name});
}

abstract class Firebase extends FirebaseAsync {
  /// Initialize the app with the given options.
  // @deprecated use async version
  App initializeApp({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  App app({String? name});
}

/// Firebase app.
abstract class App {
  /// The app name
  String? get name;

  /// The app options
  AppOptions? get options;

  /// Dispose the app.
  ///
  /// Close all added service.
  Future<void> delete();

  /// Add a service and calls its init method.
  ///
  /// Upon delete, close will be called
  Future addService(FirebaseAppService service);
}

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

  AppOptions.fromMap(Map<String, dynamic> map) {
    apiKey = map['apiKey']?.toString();
    authDomain = map['authDomain']?.toString();
    databaseURL = map['databaseURL']?.toString();
    projectId = map['projectId']?.toString();
    storageBucket = map['storageBucket']?.toString();
    messagingSenderId = map['messagingSenderId']?.toString();
    measurementId = map['measurementId']?.toString();
    appId = map['appId']?.toString();
  }

  Map<String, dynamic> toDebugMap() {
    return {'apiKey': obfuscate(apiKey), projectId!: projectId};
  }

  @override
  String toString() => toDebugMap().toString();
}

/// Attached firebase service.
///
/// Init is called
abstract class FirebaseAppService {
  /// Called when [App.addService] is called
  Future init(App app);

  /// Called when [App.delete] is called
  Future close(App app);
}
