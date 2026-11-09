# tekartik_firebase_local

`Firebase` implementation with no network and no real project, for tests,
examples and offline tools. It only manages the apps (`FirebaseLocal`,
`FirebaseAppLocal`): the local products (auth sembast/sdb, firestore
sembast/idb, storage fs) attach to its apps and store their data under the
app `localPath`.

Runs everywhere (Dart VM, Flutter, browser, node).

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_firebase_local:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_local
```

```dart
import 'package:tekartik_firebase_local/firebase_local.dart';

Future<void> main() async {
  // Unique local path (_memory1, _memory2...): two apps never share data.
  var firebase = newFirebaseMemory();
  var app = firebase.initializeApp(
    options: FirebaseAppOptions(projectId: 'my-project'),
  );
  // [DEFAULT] my-project true
  print('${app.name} ${app.projectId} ${app.isLocal}');
  print(app.localPath); // _memory1/my-project
  // Closes the products of the app.
  await app.delete();
}
```

Attach the products with their services, on the same app:
`newFirestoreServiceMemory().firestore(app)`
(`tekartik_firebase_firestore_sembast`),
`newFirebaseAuthServiceMemory().auth(app)` (`tekartik_firebase_auth_sembast`),
`newStorageServiceMemory().storage(app)` (`tekartik_firebase_storage_fs`).

## When to use what

* `newFirebaseMemory()` / `newFirebaseAppMemory()`: tests, each call isolated.
* `FirebaseLocal(localPath: ...)`: an offline app persisted on disk with io
  database factories (default path `.dart_tool/tekartik_firebase_local`).
* `newFirebaseAppLocal()`: a `FirebaseLocal` and its default app in one call.
* `initializeApp` is synchronous; the default project id is `local`, the
  default name `[DEFAULT]`.

## Common pitfalls

* `app.localPath` is `<firebase localPath>/<projectId>`: two apps of the same
  `FirebaseLocal` and project share their data (on purpose: an admin view),
  and options without a project id make `localPath` (so every io product)
  throw.
* Initializing the same name twice throws a `StateError`; `app(name:)` of an
  unknown name throws too.
* Await `app.delete()` in `tearDown`. A deleted app and its products are not
  blocked: do not use them afterwards.
* The shortcuts `newFirestoreMemory()`, `newFirebaseAuthMemory()`,
  `newStorageMemory()` each create their own app: use the services to share
  one app between products.
* Not a backend: no security rules, no server. To serve it to another
  process use `tekartik_firebase_sim`.

The [tekartik-firebase-local-apps skill](skills/tekartik-firebase-local-apps/SKILL.md)
has more examples (test context, offline app on disk, admin app).
