import 'dart:async';

export 'package:tekartik_firebase/src/firebase.dart'
    show firebaseAppNameDefault;

abstract class FirebaseAsync {
  Future<App> initializeAppAsync({AppOptions options, String name});
}

abstract class Firebase extends FirebaseAsync {
  App initializeApp({AppOptions options, String name});
}

/// Firebase app.
abstract class App {
  /// The app name
  String get name;

  /// The app options
  AppOptions get options;

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
  String apiKey;
  String authDomain;
  String databaseURL;
  String projectId;
  String storageBucket;
  String messagingSenderId;
  String measurementId;
  String appId;

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
