import 'package:firebase_core/firebase_core.dart' as flutter;
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/storage.dart';

class FirebaseFlutter implements Firebase {
  @override
  FirestoreService get firestore => null;

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
  Firestore firestore() {
    throw 'not supported';
  }

  @override
  String get name => nativeInstance.name;

  // TODO: implement options
  @override
  AppOptions get options => null;

  @override
  Storage storage() {
    throw 'not supported';
  }

}
