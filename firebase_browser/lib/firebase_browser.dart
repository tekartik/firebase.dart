import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_browser/src/firebase_browser.dart'
    as firebase_browser;

export 'package:tekartik_firebase_browser/src/firebase_browser.dart'
    show loadFirebaseJs, loadFirebaseCoreJs, loadFirebaseAuthJs;

@Deprecated('This package will receive no further updates.')
Firebase get firebaseBrowser => firebase_browser.firebaseBrowser;
