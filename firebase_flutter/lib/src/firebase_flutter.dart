import 'package:firebase_core/firebase_core.dart' as flutter;
import 'package:tekartik_firebase/firebase.dart';

class FirebaseFlutter implements Firebase {
  @override
  App initializeApp({AppOptions options, String name}) => null;
}

class AppFlutter implements App {
  final flutter.FirebaseOptions nativeOptions;
  final flutter.FirebaseApp nativeInstance;

  AppFlutter(this.nativeInstance, this.nativeOptions);

  @override
  Future delete() {
    throw 'not supported';
  }

  @override
  String get name => nativeInstance.name;

  @override
  AppOptions get options => null;

  @override
  Auth auth() {
    throw UnsupportedError('auth not supported');
  }
}
