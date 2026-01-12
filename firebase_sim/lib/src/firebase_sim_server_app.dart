import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firebase.dart';

/// One project
class FirebaseSimServerProject {
  /// Project ID.
  final String projectId;

  /// App map.
  final appMap = <String, FirebaseSimServerProjectApp>{};
  final _id = ++__id;
  static var __id = 0;

  /// Constructor.
  FirebaseSimServerProject(this.projectId);

  @override
  String toString() {
    // Initialization logic for the simulated Firebase app
    return 'FirebaseSimServerProject($projectId)';
  }

  /// This is the only one used for initialization, named projectId_DEFAULT
  late final appDelegate = FirebaseSimServerProjectAppDelegate(project: this);

  String _mapKey(String appName) => '$appName$_id';

  /// Get or create app.
  FirebaseSimServerProjectApp app(String appName) {
    var mapKey = _mapKey(appName);
    return appMap[mapKey] ??= FirebaseSimServerProjectApp(this, mapKey);
  }

  /// Delete app.
  Future<void> deleteApp(String appName) async {
    var mapKey = _mapKey(appName);
    appMap.remove(mapKey);
    if (appMap.isEmpty) {
      // Clean up project if no more apps
      await appDelegate.firebaseDeleteApp();
      // (handled by the server/channel)
    }
  }
}

/// App delegate.
class FirebaseSimServerProjectAppDelegate {
  /// The project instance.
  final FirebaseSimServerProject project;

  /// Project ID.
  String get projectId => project.projectId;

  /// Firebase app instance.
  FirebaseApp? app;

  /// App name.
  late final String appName = '${projectId}_DEFAULT';

  final _lock = Lock();

  /// Constructor.
  FirebaseSimServerProjectAppDelegate({required this.project});

  /// Do it only once
  Future<FirebaseApp?> firebaseInitializeApp(
    Firebase firebase,
    AppOptions options,
  ) {
    return _lock.synchronized(() async {
      app ??= await firebase.initializeAppAsync(
        options: options,
        name: appName,
      );
      return app;
    });
  }

  /// Delete Firebase app.
  Future<void> firebaseDeleteApp() async {
    await _lock.synchronized(() async {
      await app?.delete();
      app = null;
    });
  }
}

/// One per app in a project (name or client channel)
class FirebaseSimServerProjectApp {
  static var _lastAppId = 0;

  /// App ID.
  final int appId = ++_lastAppId;

  /// Project instance.
  final FirebaseSimServerProject project;

  /// Project ID.
  String get projectId => project.projectId;

  /// App name.
  final String appName;

  /// Set later
  FirebaseApp? get app => project.appDelegate.app;

  /// Constructor.
  FirebaseSimServerProjectApp(this.project, this.appName);

  /// Do it only once
  Future<void> firebaseInitializeApp(
    Firebase firebase,
    AppOptions options,
  ) async {
    await project.appDelegate.firebaseInitializeApp(firebase, options);
  }

  /// Delete Firebase app.
  Future<void> firebaseDeleteApp() async {
    /// Remove app reference, if down to 0 it will be deleted
    await project.deleteApp(appName);
  }

  @override
  String toString() {
    // Initialization logic for the simulated Firebase app
    return 'FirebaseSimServerProjectApp($projectId, $appName)';
  }
}
