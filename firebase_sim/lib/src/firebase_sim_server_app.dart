import 'package:tekartik_firebase/firebase.dart';

/// One project
class FirebaseSimServerProject {
  final String projectId;
  final appMap = <String, FirebaseSimServerProjectApp>{};
  final _id = __id++;
  static var __id = 0;
  FirebaseSimServerProject(this.projectId);

  @override
  String toString() {
    // Initialization logic for the simulated Firebase app
    return 'FirebaseSimServerProject($projectId)';
  }

  late final appDelegate = FirebaseSimServerProjectApp(
    this,
    'TEKARTIK_FIREBASESIM_DELEGATE',
  );

  FirebaseSimServerProjectApp app(String appName) {
    var mapKey = '$appName$_id';
    return appMap[mapKey] ??= FirebaseSimServerProjectApp(this, mapKey);
  }
}

/// One per app in a project (name or client channel)
class FirebaseSimServerProjectApp {
  FirebaseSimServerProject project;
  String get projectId => project.projectId;
  final String appName;

  /// Set later
  FirebaseApp? app;
  FirebaseSimServerProjectApp(this.project, this.appName);

  /// Do it only once
  void firebaseInitializeApp(Firebase firebase, AppOptions options) {
    app ??= firebase.initializeApp(options: options, name: appName);
  }

  @override
  String toString() {
    // Initialization logic for the simulated Firebase app
    return 'FirebaseSimServerProjectApp($projectId, $appName)';
  }
}
