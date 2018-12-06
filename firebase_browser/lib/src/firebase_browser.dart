import 'dart:async';

import 'package:firebase/src/interop/auth_interop.dart';

import 'package:firebase/firebase.dart' as native;
import 'package:firebase/firestore.dart' as native;
import 'package:tekartik_browser_utils/js_utils.dart';
import 'package:tekartik_firebase/firebase.dart';
export 'package:firebase/firebase.dart';

String firebaseJsVersion = "5.5.2";

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

  @override
  Auth auth() => AuthBrowserImpl(nativeApp.auth());
}

abstract class AuthBrowser {
  Stream<native.User> get onAuthStateChanged;

  Future signOut();

  Future signInWithRedirect(native.AuthProvider authProvider);

  Future<native.UserCredential> signInPopup(native.AuthProvider authProvider);
}

class AuthBrowserImpl implements Auth, AuthBrowser {
  final native.Auth nativeAuth;

  AuthBrowserImpl(this.nativeAuth);

  Stream<native.User> get onAuthStateChanged => nativeAuth.onAuthStateChanged;

  @override
  Future signOut() => nativeAuth.signOut();

  @override
  Future<native.UserCredential> signInPopup(
          native.AuthProvider<AuthProviderJsImpl> authProvider) =>
      nativeAuth.signInWithPopup(authProvider);

  @override
  Future signInWithRedirect(
          native.AuthProvider<AuthProviderJsImpl> authProvider) =>
      nativeAuth.signInWithRedirect(authProvider);
}

FirebaseBrowser _firebaseBrowser;

FirebaseBrowser get firebaseBrowser => _firebaseBrowser ??= FirebaseBrowser();
