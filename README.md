# firebase.dart

Firebase dart common interface and implementation for Browser, VM, node and flutter


## Firebase Initialization

### Usage in browser

```dart
import 'package:tekartik_firebase_browser/firebase_browser.dart';

void main() {
  var firebase = firebaseNode;
  // ...
}
```  

### Usage on node

```dart
import 'package:tekartik_firebase_node/firebase_node.dart';

void main() {
  var firebase = firebaseNode;
  // ...
}
```  

### Usage on flutter

```dart
import 'package:tekartik_firebase_flutter/firebase_flutter.dart';

void main() {
  var firebase = firebaseFlutter;
  // ...
}
```  

### Usage on sembast (io simulation)

```dart
import 'package:tekartik_firebase_sembast/firebase_sembast.dart';

void main() {
  var firebase = firebaseSembast;
  // ...
}
```  

## App initialization

```dart
var options =  new AppOptions(
    apiKey: "your_api_key",
    authDomain: "xxxx",
    databaseURL: "xxxx",
    projectId: "xxxx",
    storageBucket: "xxxx",
    messagingSenderId: "xxxx"); 
var app =  firebase.initializeApp(options);
  // ...
}
```  

## Firestore access

```dart
var firestore = app.firestore();
// read a document
var data = (await firestore.doc('collections/document').get()).data;
// ...

```  

## Storage access

Experimental, not fully implemented yet
```dart
var storage = app.storage();
// ...

```  

