import 'package:tekartik_firebase/firebase.dart';

import 'package:tekartik_firebase_browser/src/firebase_browser.dart' as _;
export 'package:tekartik_firebase_browser/src/firebase_browser.dart'
    show
        loadFirebaseJs,
        loadFirebaseCoreJs,
        loadFirebaseAuthJs,
        AuthBrowser,
        User,
        UserCredential,
        GoogleAuthProvider;

Firebase get firebaseBrowser => _.firebaseBrowser;
