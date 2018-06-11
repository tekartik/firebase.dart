import 'package:sembast/sembast_io.dart';
import 'package:tekartik_firebase_sembast/src/firebase_sembast.dart';

FirebaseSembast _firebaseSembastIo;

FirebaseSembast get firebaseSembastIo => _firebaseSembastIo =
    _firebaseSembastIo ?? new FirebaseSembast(ioDatabaseFactory);
