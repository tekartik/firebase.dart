import 'package:tekartik_firebase/firebase.dart';

import 'firebase_mixin.dart';

/// Async interface, needed for flutter.
abstract class FirebaseAsync {
  /// Initialize the app with the given options.
  Future<FirebaseApp> initializeAppAsync({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  Future<FirebaseApp> appAsync({String? name});
}

/// Firebase interface.
abstract class Firebase extends FirebaseAsync {
  /// Initialize the app with the given options.
  // @deprecated use async version
  FirebaseApp initializeApp({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  FirebaseApp app({String? name});

  /// True if firebase is local (i.e. FirebaseLocal, not rest, nor node, nor flutter)
  bool get isLocal;

  /// Get all apps
  static List<FirebaseApp> get apps => List.of(firebaseApps);
}
