import 'dart:async';

import 'package:firebase/firebase.dart' as native;
import 'package:firebase/firestore.dart' as native;
import 'package:tekartik_browser_utils/js_utils.dart';
import 'package:tekartik_firebase/firebase.dart';

String firebaseJsVersion = "5.1.0";

JavascriptScriptLoader firebaseJsLoader = JavascriptScriptLoader(
    "https://www.gstatic.com/firebasejs/$firebaseJsVersion/firebase-app.js");
JavascriptScriptLoader firestoreJsLoader = JavascriptScriptLoader(
    "https://www.gstatic.com/firebasejs/$firebaseJsVersion/firebase-firestore.js");

Future loadFirebaseCoreJs() async {
  await firebaseJsLoader.load();
}

Future loadFirebaseFirestoreJs() async {
  await firestoreJsLoader.load();
}

//JavascriptScriptLoader firebaseJsLoader = new JavascriptScriptLoader("https://www.gstatic.com/firebasejs/4.2.0/firebase.js");
Future loadFirebaseJs() async {
  await loadFirebaseCoreJs();
  await loadFirebaseFirestoreJs();
}

class FirebaseBrowser implements Firebase {
  @override
  App initializeApp({AppOptions options, String name}) {
    options ??= AppOptions();
    native.App nativeApp = native.initializeApp(
        projectId: options.projectId,
        storageBucket: options.storageBucket,
        messagingSenderId: options.messagingSenderId,
        databaseURL: options.databaseURL,
        authDomain: options.authDomain,
        apiKey: options.apiKey,
        name: name);
    if (nativeApp == null) {
      return null;
    }
    return AppBrowser(nativeApp);
  }
}

class AppBrowser implements App {
  final native.App nativeApp;

  AppBrowser(this.nativeApp);

  @override
  Future delete() async {
    await nativeApp.delete();
  }

  @override
  String get name => nativeApp.name;

  @override
  AppOptions get options {
    var nativeOptions = nativeApp.options;

    if (nativeOptions != null) {
      return AppOptions(
          apiKey: nativeOptions.apiKey,
          authDomain: nativeOptions.authDomain,
          messagingSenderId: nativeOptions.messagingSenderId,
          storageBucket: nativeOptions.storageBucket,
          projectId: nativeOptions.projectId,
          databaseURL: nativeOptions.databaseURL);
    } else {
      return null;
    }
  }
}

FirebaseBrowser _firebaseBrowser;

FirebaseBrowser get firebaseBrowser => _firebaseBrowser ??= FirebaseBrowser();
