---
name: tekartik-firebase-local-apps
description: >-
  Use when a Dart or Flutter test, example or offline app needs a Firebase
  app without any backend: tekartik_firebase_local gives FirebaseLocal,
  FirebaseAppLocal, newFirebaseMemory, newFirebaseAppMemory and
  newFirebaseAppLocal, the app that the local auth (sdb, sembast, local),
  firestore (sembast, idb) and storage (fs) services attach to, and the
  localPath layout those services store their data under.
---

# tekartik_firebase_local apps

`FirebaseLocal` is the `Firebase` implementation with no network and no real
project: it only manages the app lifecycle and `isLocal` is `true`. Its apps
are `FirebaseAppLocal`, the type the local product backends cast to and whose
`localPath` they store their data under.

## Guidelines

* Import only `package:tekartik_firebase_local/firebase_local.dart`. It
  re-exports `package:tekartik_firebase/firebase.dart` (`Firebase`,
  `FirebaseApp`, `FirebaseAppOptions` and its alias `AppOptions`,
  `firebaseAppNameDefault`, the `projectId` extension getter).
* Prefer `newFirebaseMemory()` (or `newFirebaseAppMemory()`) in tests: each
  call gets a unique `localPath` (`_memory1`, `_memory2`, ...) so two
  instances never share data, even with memory database factories keyed by
  path. `newFirebaseAppLocal()` builds a `FirebaseLocal` plus its default app
  in one call.
* `FirebaseLocal()` alone defaults `localPath` to
  `.dart_tool/tekartik_firebase_local`; `initializeApp()` defaults the
  projectId to `local` and the name to `firebaseAppNameDefault`
  (`[DEFAULT]`). Pass `options: AppOptions(projectId: ...)` to control the
  data folder name.
* `initializeApp` is synchronous and returns a typed `FirebaseAppLocal`, so
  no cast is needed. `initializeAppAsync` exists only for code written
  against the generic `FirebaseAsync` interface.
* Initializing the same name twice on one `FirebaseLocal` throws a
  `StateError`. Use a distinct `name:` for a second app, or
  `await app.delete()` first. Look up an existing app with
  `firebase.app(name: ...)`.
* Two apps of the same `FirebaseLocal` with the same projectId share
  `localPath`, hence the same databases: this is the way to get an "admin"
  view on the data of the default app.
* Always `await app.delete()` in `tearDown`/`tearDownAll`: it closes the
  services registered with `addService` and removes the app from the global
  registry (`FirebaseApp.instance` is the latest initialized app).
* `app.localPath` is `join(firebase.localPath, projectId)`. Local services
  store under it: auth sdb/sembast `auth.db`, firestore sembast
  `firestore.db`, firestore sdb `firestore/firestore.sdb`, storage fs
  `storage/<bucket>` (unless the storage service has a `basePath`). With a
  memory factory the path is only a namespace; with an io factory it is a
  real directory, so choose `localPath` and `projectId` deliberately for
  persistent offline apps.
* Attach products through their service `auth(app)`, `firestore(app)` and
  `storage(app)` methods with the same `FirebaseAppLocal`:
  `FirebaseAuthServiceSdb(sdbFactory:)` (`tekartik_firebase_auth_sdb`),
  `FirebaseAuthServiceSembast(databaseFactory:)`
  (`tekartik_firebase_auth_sembast`), `FirebaseAuthServiceLocal`
  (`tekartik_firebase_auth_local`), `newFirestoreServiceMemory()` and
  `newFirestoreServiceSembast(databaseFactory:)`
  (`tekartik_firebase_firestore_sembast`), `sdbFactory.firestoreService`
  (`tekartik_firebase_firestore_idb`), `newStorageServiceMemory()` and
  `newStorageServiceFs(fileSystem:)` (`tekartik_firebase_storage_fs`).
* The shortcuts `newFirebaseAuthSdbMemory()`, `newFirebaseAuthMemory()`,
  `newFirestoreMemory()` and `newStorageMemory()` each create their own
  `newFirebaseAppMemory()`: avoid them when products must share one app.
* Never pass a REST, node or Flutter `FirebaseApp` to a local service (the
  services assert on `FirebaseAppLocal`), and never pass a `FirebaseAppLocal`
  to a real backend service.
* Not a backend: no security rules, no server. For a real project use
  `tekartik_firebase_rest`, `tekartik_firebase_node` or `tekartik_firebase_flutter`;
  to serve a `FirebaseLocal` to another process use `tekartik_firebase_sim`.
* `AppLocal` is a legacy typedef of `FirebaseAppLocal`. To validate a
  `Firebase` implementation run `runFirebaseTests` from `tekartik_firebase_test`.

## Examples

### Test context: auth and firestore on one in-memory app

```dart
import 'package:tekartik_app_cv_sdb/app_cv_sdb.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_firestore_sembast/firestore_sembast.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:test/test.dart';

void main() {
  late FirebaseLocal firebase;
  late FirebaseAppLocal app;
  late FirebaseAuth auth;
  late Firestore firestore;

  setUp(() {
    firebase = newFirebaseMemory();
    app = firebase.initializeApp(options: AppOptions(projectId: 'test'));
    auth = FirebaseAuthServiceSdb(sdbFactory: sdbFactoryMemory).auth(app);
    firestore = newFirestoreServiceMemory().firestore(app);
  });
  tearDown(() => app.delete());

  test('isolated app', () async {
    expect(app.isLocal, isTrue);
    expect(app.projectId, 'test');
    await firestore.doc('users/1').set({'name': 'alice'});
    expect((await firestore.doc('users/1').get()).exists, isTrue);
  });
}
```

### Offline app persisted on disk (sembast io)

```dart
import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tekartik_firebase_auth_sembast/auth_sembast.dart';
import 'package:tekartik_firebase_firestore_sembast/firestore_sembast.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';

/// Data lands in `.local/firebase/my_app/auth.db` and `firestore.db`.
({FirebaseAppLocal app, FirebaseAuth auth, Firestore firestore})
initOfflineApp() {
  var firebase = FirebaseLocal(localPath: join('.local', 'firebase'));
  var app = firebase.initializeApp(options: AppOptions(projectId: 'my_app'));
  var auth = FirebaseAuthServiceSembast(
    databaseFactory: databaseFactoryIo,
  ).auth(app);
  var firestore = newFirestoreServiceSembast(
    databaseFactory: databaseFactoryIo,
  ).firestore(app);
  return (app: app, auth: auth, firestore: firestore);
}
```

### Second named app sharing the same data

```dart
import 'package:tekartik_firebase_local/firebase_local.dart';

void main() {
  var firebase = newFirebaseMemory();
  var app = firebase.initializeApp();
  // Same projectId ('local') so same localPath: services share databases.
  var adminApp = firebase.initializeApp(name: 'admin');
  assert(adminApp.localPath == app.localPath);
  assert(identical(firebase.app(name: 'admin'), adminApp));
  // firebase.initializeApp() again would throw ('[DEFAULT]' exists).
}
```
