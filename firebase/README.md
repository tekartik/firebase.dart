# tekartik_firebase

Platform neutral Firebase core: create and look up a `FirebaseApp`, configure
it with `FirebaseAppOptions`, and get its products (auth, firestore, storage,
functions) from their services. The same code runs on Flutter, the Dart VM,
the browser and node: only the backend changes.

This package has no backend. Pick one below; each re-exports
`package:tekartik_firebase/firebase.dart`.

## Getting started

Git package, not on pub.dev. Depend on a backend, for example the in memory
one (tests, offline tools):

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
  // Swap for firebaseFlutter, firebaseRest, firebaseNode...
  var firebase = newFirebaseMemory();
  var app = firebase.initializeApp(
    options: FirebaseAppOptions(projectId: 'my-project'),
  );
  print('${app.name} ${app.projectId}'); // [DEFAULT] my-project
  // Closes the products of the app.
  await app.delete();
}
```

Shared code depends on this package only:

```yaml
dependencies:
  tekartik_firebase:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase
```

## Backends

| Backend | Package (repo, path) | Entry point | Runs on |
|---|---|---|---|
| In memory | `tekartik_firebase_local` (firebase.dart, `firebase_local`) | `newFirebaseMemory()`, `newFirebaseAppMemory()` | everywhere (tests) |
| Flutter | `tekartik_firebase_flutter` (firebase_flutter, `firebase_flutter`) | `firebaseFlutter` | Flutter (the FlutterFire platforms) |
| REST | `tekartik_firebase_rest` (firebase_rest.dart, `firebase_rest`) | `firebaseRest` | Dart VM (service account or user access token) |
| Node | `tekartik_firebase_node` (firebase_node.dart, `firebase_node`) | `firebaseNode` | node, Cloud Functions |
| Admin SDK | `tekartik_firebase_admin_sdk` (firebase_admin_sdk.dart, `firebase_admin_sdk`) | `firebaseAdminSdk` | Dart VM server |

All the repos are under `https://github.com/tekartik/`.

## When to use what

* `Firebase` (sync) / `FirebaseAsync` (async): create an app with
  `initializeApp(options:, name:)`, get it back with `app(name:)`. Write shared
  code against `FirebaseAsync` (`initializeAppAsync`, `appAsync`): Flutter
  initializes asynchronously.
* `FirebaseApp`: `name`, `options`, `projectId`, `isLocal` (memory backend),
  `hasAdminCredentials`, `delete()`. Pass the app (or the product) around.
* `FirebaseAppOptions` (alias `AppOptions`): `apiKey`, `projectId`,
  `storageBucket`... from the constructor or `FirebaseAppOptions.fromMap(json)`.
* Products are created by their service, never by the app:
  `firestoreService.firestore(app)`, `authService.auth(app)`... The service
  keeps one instance per app, also returned by `app.getProduct<Firestore>()`.
* `package:tekartik_firebase/firebase_admin.dart`: `FirebaseAdmin` and the
  credential types (REST, node, admin sdk).
* `package:tekartik_firebase/firebase_mixin.dart`: the mixins to write a
  backend or a product, see [example/main.dart](example/main.dart).

## Common pitfalls

* Initializing the same app name twice throws a `StateError`: use
  `app(name:)`. `app(name:)` of an unknown name throws too.
* Await `app.delete()` when done (`tearDown` in tests): it closes the services
  and disposes the products. Do not use the app or its products afterwards
  (nothing prevents it, but they are closed).
* `FirebaseApp.instance` is the last initialized app of any backend: only for
  single app programs.
* `app.projectId` assumes the options have a project id.
* Log `options.toDebugMap()`: it keeps the project id and an obfuscated api key.

The [tekartik-firebase-apps skill](skills/tekartik-firebase-apps/SKILL.md) has
more examples (tests with a memory app, a product service, a backend).
