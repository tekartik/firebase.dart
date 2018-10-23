import 'dart:async';
import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/storage.dart';
import 'package:tekartik_firebase_sembast/src/firestore_sembast.dart';
import 'package:tekartik_firebase_sembast/src/storage_sembast.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_memory.dart' as sembast;

class FirestoreServiceSembast implements FirestoreService {
  @override
  bool get supportsQuerySelect => true;

  @override
  bool get supportsDocumentSnapshotTime => true;
}

class FirebaseSembast implements Firebase {
  final sembast.DatabaseFactory databaseFactory;

  @override
  FirestoreService firestore = FirestoreServiceSembast();

  FirebaseSembast(this.databaseFactory);
  @override
  App initializeApp({AppOptions options, String name}) {
    return AppSembast(this, options, name ?? '[DEFAULT]');
  }
}

class AppSembast implements App {
  final FirebaseSembast firebase;
  String get localPath => join(".dart_tool", "tekartik_firebase_sembast");

  FirestoreSembast _firestore;
  StorageSembast _storage;

  @override
  final AppOptions options;

  bool deleted = false;
  @override
  String name;

  AppSembast(this.firebase, this.options, this.name);

  @override
  Firestore firestore() {
    assert(!deleted);
    _firestore ??= FirestoreSembast(this);
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
    _storage ??= StorageSembast(this);
    return _storage;
  }
}

// For now only firestore
FirebaseSembast _firebaseSembastMemory;
FirebaseSembast get firebaseSembastMemory => _firebaseSembastMemory =
    _firebaseSembastMemory ?? FirebaseSembast(sembast.memoryDatabaseFactory);
