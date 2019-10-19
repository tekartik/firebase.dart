import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart' as native;
import 'package:tekartik_firebase/firebase.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase/src/firebase_mixin.dart';

FirebaseNode _firebaseNode;

FirebaseNode get firebaseNode =>
    _firebaseNode ??= FirebaseNode._(native.FirebaseAdmin.instance);

//import 'package:firebase_functions_interop/
class FirebaseNode with FirebaseMixin {
  FirebaseNode._(this.nativeInstance);

  final native.FirebaseAdmin nativeInstance;

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

class AppNode with FirebaseAppMixin {
  final native.App nativeInstance;

  AppNode(this.nativeInstance);

  @override
  String get name => nativeInstance.name;

  @override
  Future delete() async {
    await nativeInstance.delete();
    await closeServices();
  }

  @override
  AppOptions get options => _wrapAppOptions(nativeInstance.options);
}
