import 'package:firebase_core/firebase_core.dart' as flutter;
import 'package:tekartik_firebase/firebase.dart';

class FirebaseFlutter implements FirebaseAsync, Firebase {
  @override
  Future<App> initializeAppAsync({AppOptions options, String name}) async {
    flutter.FirebaseOptions fbOptions;
    flutter.FirebaseApp nativeApp;
    bool isDefault = false;
    if (options != null) {
      nativeApp =
          await flutter.FirebaseApp.configure(name: name, options: fbOptions);
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

class AppFlutter implements App {
  final bool isDefault;
  @override
  final AppOptions options;
  final flutter.FirebaseApp nativeInstance;

  AppFlutter({this.nativeInstance, this.options, this.isDefault});

  @override
  Future delete() {
    throw 'not supported';
  }

  @override
  String get name => nativeInstance.name;
}

FirebaseFlutter _firebaseFlutter;
FirebaseFlutter get firebaseFlutter => _firebaseFlutter ??= FirebaseFlutter();
