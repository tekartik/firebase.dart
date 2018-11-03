import 'dart:async';
import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_memory.dart' as sembast;

class FirebaseSembast implements Firebase {
  final sembast.DatabaseFactory databaseFactory;

  FirebaseSembast(this.databaseFactory);
  @override
  App initializeApp({AppOptions options, String name}) {
    return AppSembast(this, options, name ?? '[DEFAULT]');
  }
}

class AppSembast implements App {
  final FirebaseSembast firebase;
  String get localPath => join(".dart_tool", "tekartik_firebase_sembast");

  @override
  final AppOptions options;

  bool deleted = false;
  @override
  String name;

  AppSembast(this.firebase, this.options, this.name);

  @override
  Future<Null> delete() async {
    deleted = true;
  }
}

// For now only firestore
FirebaseSembast _firebaseSembastMemory;
FirebaseSembast get firebaseSembastMemory => _firebaseSembastMemory =
    _firebaseSembastMemory ?? FirebaseSembast(sembast.memoryDatabaseFactory);
