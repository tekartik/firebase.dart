import 'dart:async';

import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/storage.dart';

export 'package:tekartik_firebase/src/firebase.dart'
    show firebaseAppNameDefault;

abstract class Firebase {
  App initializeApp({AppOptions options, String name});

  // if firestore is available
  FirestoreService get firestore;
}

abstract class App {
  String get name;

  AppOptions get options;

  Firestore firestore();

  Storage storage();

  Future delete();
}

class AppOptions {
  String apiKey;
  String authDomain;
  String databaseURL;
  String projectId;
  String storageBucket;
  String messagingSenderId;

  AppOptions(
      {this.apiKey,
      this.authDomain,
      this.databaseURL,
      this.projectId,
      this.storageBucket,
      this.messagingSenderId});
}
