import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_flutter/src/firebase_flutter.dart'
    as firebase_flutter;

FirebaseAsync get firebaseFlutterAsync => firebase_flutter.firebaseFlutter;

Firebase get firebaseFlutter => firebase_flutter.firebaseFlutter;
