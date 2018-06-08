import 'dart:async';
import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/storage.dart';
import 'package:tekartik_firebase_sembast/src/firestore_sembast.dart';
import 'package:tekartik_firebase_sembast/src/storage_sembast.dart';

class FirestoreServiceIo implements FirestoreService {
  @override
  bool get supportsQuerySelect => true;
}

class FirebaseSembast implements Firebase {
  @override
  FirestoreService firestore = new FirestoreServiceIo();
  @override
  App initializeApp({AppOptions options, String name}) {
    return new AppSembast(options, name ?? '[DEFAULT]');
  }
}

class AppSembast implements App {
  String get localPath => join(".dart_tool", "firebase_admin_shim");

  FirestoreIo _firestore;
  StorageIo _storage;

  @override
  final AppOptions options;

  bool deleted = false;
  @override
  String name;

  AppSembast(this.options, this.name);

  @override
  Firestore firestore() {
    assert(!deleted);
    _firestore ??= new FirestoreIo(this);
    return _firestore;
  }

  @override
  Future<Null> delete() async {
    deleted = true;
    // clear firestore subscription
    await _firestore?.close();
  }

  @override
  Storage storage() {
    assert(!deleted);
    _storage ??= new StorageIo(this);
    return _storage;
  }
}

FirebaseSembast _firebaseSembast;
FirebaseSembast get firebaseSembast =>
    _firebaseSembast = _firebaseSembast ?? new FirebaseSembast();

@deprecated
FirebaseSembast get ioFirebaseAdmin => firebaseSembast;
