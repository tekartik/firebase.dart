import 'dart:async';

import 'package:firebase/firebase.dart' as native;
import 'package:firebase/firestore.dart' as native;
import 'package:tekartik_browser_utils/js_utils.dart';
import 'package:tekartik_firebase/firebase.dart';

import 'package:tekartik_firebase/src/firebase_mixin.dart'; // ignore: implementation_imports
import 'package:tekartik_firebase_browser/src/common/firebase_js_version.dart';

// 2018-12-05 to deprecate
JavascriptScriptLoader firebaseJsLoader = JavascriptScriptLoader(
    "https://www.gstatic.com/firebasejs/$firebaseJsVersion/firebase-app.js");

String getJavascriptAppJsFile({String version}) {
  version ??= firebaseJsVersion;
  return "https://www.gstatic.com/firebasejs/$version/firebase-app.js";
}

String getJavascriptJsFile({String version}) {
  version ??= firebaseJsVersion;
  return "https://www.gstatic.com/firebasejs/$version/firebase.js";
}

String getJavascriptAuthJsFile({String version}) {
  version ??= firebaseJsVersion;
  return "https://www.gstatic.com/firebasejs/$version/firebase-auth.js";
}

var _firebaseCoreJsLoader = JavascriptScriptLoader(
    "https://www.gstatic.com/firebasejs/$firebaseJsVersion/firebase-app.js");

/// does not work with build_runner
Future loadFirebaseCoreJs() async {
  await _firebaseCoreJsLoader.load();
}

/// does not work with build_runner
Future loadFirebaseAuthJs({String version}) async {
  await loadJavascriptScript(getJavascriptAppJsFile(version: version));
}

//JavascriptScriptLoader firebaseJsLoader = new JavascriptScriptLoader("https://www.gstatic.com/firebasejs/4.2.0/firebase.js");
Future loadFirebaseJs({String version}) async {
  await loadJavascriptScript(getJavascriptJsFile(version: version));
}

class FirebaseBrowser with FirebaseMixin {
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

class AppBrowser with FirebaseAppMixin {
  final native.App nativeApp;

  AppBrowser(this.nativeApp);

  @override
  Future delete() async {
    await nativeApp.delete();
    await closeServices();
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

  @override
  String toString() => 'AppBrowser(${options.projectId}, $name)';
}

FirebaseBrowser _firebaseBrowser;

FirebaseBrowser get firebaseBrowser => _firebaseBrowser ??= FirebaseBrowser();
