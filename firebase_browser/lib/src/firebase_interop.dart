@JS()
library tekartik_firebase_interop;

import 'package:firebase/src/interop/app_interop.dart' show AppJsImpl;
import 'package:firebase/src/interop/firebase_interop.dart'
    show FirebaseOptions;
import 'package:js/js.dart';

@JS()
@anonymous
class FirebaseJs {
  external AppJsImpl initializeApp(FirebaseOptions options, [String name]);
}

// Global object when loading the js in a simple way
@JS('firebase')
FirebaseJs firebaseJs;
