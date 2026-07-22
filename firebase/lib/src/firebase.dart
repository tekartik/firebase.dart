import 'package:tekartik_firebase/firebase.dart';

import 'firebase_mixin.dart';

/// Asynchronous counterpart of [Firebase], for platforms (e.g. Flutter) that
/// require app creation and lookup to be asynchronous.
abstract class FirebaseAsync {
  /// Initializes and returns a new [FirebaseApp].
  ///
  /// [options] configures the app (API key, project id, ...). If omitted,
  /// platform-specific default options are used, when supported.
  ///
  /// [name] identifies the app when more than one app is needed on the same
  /// [Firebase] instance. If omitted, [firebaseAppNameDefault] is used.
  ///
  /// Returns the newly created [FirebaseApp] once initialization completes.
  ///
  /// Most implementations throw a [StateError] if an app named [name] has
  /// already been initialized.
  Future<FirebaseApp> initializeAppAsync({AppOptions? options, String? name});

  /// Retrieves an existing [FirebaseApp].
  ///
  /// [name] identifies the app to look up. If omitted, [firebaseAppNameDefault]
  /// is used, i.e. the default app.
  ///
  /// Returns the matching [FirebaseApp] once available.
  ///
  /// Throws if no app named [name] has been initialized.
  Future<FirebaseApp> appAsync({String? name});
}

/// Firebase entry point used to synchronously create and retrieve
/// [FirebaseApp] instances.
abstract class Firebase extends FirebaseAsync {
  /// Initializes and returns a new [FirebaseApp].
  ///
  /// [options] configures the app (API key, project id, ...). If omitted,
  /// platform-specific default options are used, when supported.
  ///
  /// [name] identifies the app when more than one app is needed on the same
  /// [Firebase] instance. If omitted, [firebaseAppNameDefault] is used.
  ///
  /// Returns the newly created [FirebaseApp].
  ///
  /// Most implementations throw a [StateError] if an app named [name] has
  /// already been initialized.
  ///
  /// Prefer [initializeAppAsync] on platforms (e.g. Flutter) where
  /// initialization must be asynchronous.
  FirebaseApp initializeApp({AppOptions? options, String? name});

  /// Retrieves an existing [FirebaseApp].
  ///
  /// [name] identifies the app to look up. If omitted, [firebaseAppNameDefault]
  /// is used, i.e. the default app.
  ///
  /// Returns the matching [FirebaseApp].
  ///
  /// Throws if no app named [name] has been initialized.
  FirebaseApp app({String? name});

  /// `true` if this [Firebase] implementation is a local/in-memory one (used
  /// for testing), as opposed to a real backend (REST, Node.js, Flutter).
  bool get isLocal;

  /// All [FirebaseApp] instances currently initialized, across every
  /// [Firebase] implementation in the process.
  static List<FirebaseApp> get apps => List.of(firebaseApps);
}
