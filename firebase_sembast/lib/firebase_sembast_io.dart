import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sembast/src/firebase_sembast_io.dart' as _;

// Allow overidding the default bucket path
export 'package:tekartik_firebase_sembast/src/storage_sembast.dart'
    show firebaseSembastIoDefaultBucketLocalPath;

Firebase get firebaseSembastIo => _.firebaseSembastIo;
