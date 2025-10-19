import 'package:tekartik_firebase/firebase.dart';

/// Async interface, needed for flutter.
abstract class FirebaseAsync {
  /// Initialize the app with the given options.
  Future<App> initializeAppAsync({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  Future<App> appAsync({String? name});
}

/// Firebase interface.
abstract class Firebase extends FirebaseAsync {
  /// Initialize the app with the given options.
  // @deprecated use async version
  App initializeApp({AppOptions? options, String? name});

  /// Retrieves an existing instance of an App.
  App app({String? name});

  /// True if firebase is local (i.e. FirebaseLocal, not rest, nor node, nor flutter
  bool get isLocal;
}
