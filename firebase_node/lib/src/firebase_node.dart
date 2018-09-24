import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart' as native;
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/storage.dart';
import 'package:tekartik_firebase_node/src/firestore_node.dart';
import 'package:tekartik_firebase_node/src/storage_node.dart';
import 'package:tekartik_firebase_node/src/storage_bindings.dart' as native;

Firebase _firebaseNode;
Firebase get firebaseNode =>
    _firebaseNode ??= FirebaseNode._(native.FirebaseAdmin.instance);

//import 'package:firebase_functions_interop/
class FirebaseNode implements Firebase {
  FirebaseNode._(this.nativeInstance);

  final native.FirebaseAdmin nativeInstance;

  @override
  var firestore = FirestoreServiceNode();

  @override
  App initializeApp({AppOptions options, String name}) {
    // Invalid Firebase app options passed as the first argument to initializeApp() for the app named "test". Options must be a non-null object.
    // if options is null, it means we are using it in a server
    // hence no name...
    if (options == null) {
      name = null;
    }
    return AppNode(
        nativeInstance.initializeApp(_unwrapAppOptions(options), name));
  }
}

native.AppOptions _unwrapAppOptions(AppOptions appOptions) {
  if (appOptions != null) {
    return native.AppOptions(
        databaseURL: appOptions.databaseURL,
        projectId: appOptions.projectId,
        storageBucket: appOptions.storageBucket);
  }
  return null;
}

AppOptions _wrapAppOptions(native.AppOptions nativeInstance) {
  if (nativeInstance != null) {
    return AppOptions(
        databaseURL: nativeInstance.databaseURL,
        projectId: nativeInstance.projectId,
        storageBucket: nativeInstance.storageBucket);
  }
  return null;
}

class AppNode implements App {
  final native.App nativeInstance;

  AppNode(this.nativeInstance);

  @override
  String get name => nativeInstance.name;

  @override
  Future delete() => nativeInstance.delete();

  @override
  Firestore firestore() => FirestoreNode(nativeInstance.firestore());

  @override
  Storage storage() {
    native.Storage nativeStorage =
        // ignore: invalid_use_of_protected_member
        (nativeInstance.nativeInstance as native.StorageApp).storage();
    if (nativeStorage != null) {
      return StorageNode(nativeStorage);
    }
    return null;
  }

  @override
  AppOptions get options => _wrapAppOptions(nativeInstance.options);
}
