import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_browser/src/firebase_browser.dart' as _;

export 'package:firebase/firebase.dart'
    show User, UserCredential, GoogleAuthProvider;
export 'package:tekartik_firebase_browser/src/firebase_browser.dart'
    show loadFirebaseJs, loadFirebaseCoreJs, loadFirebaseAuthJs;

Firebase get firebaseBrowser => _.firebaseBrowser;
