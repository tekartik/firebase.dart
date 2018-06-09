import 'package:tekartik_firebase/firebase.dart';

import 'src/firebase_browser.dart' as _;
export 'src/firebase_browser.dart'
    show loadFirebaseJs, loadFirebaseFirestoreJs, loadFirebaseCoreJs;

Firebase get firebaseBrowser => _.firebaseBrowser;
