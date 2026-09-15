---
name: tekartik-firebase-apps
description: >-
  Use when initializing, looking up or deleting Firebase apps with the
  tekartik_firebase abstraction (Firebase, FirebaseAsync, FirebaseApp,
  FirebaseAppOptions), when attaching a product (auth, firestore, storage,
  functions) to an app through its service, when reading admin credentials
  (FirebaseAdmin) or when implementing a new Firebase backend or product
  service with the mixins of firebase_mixin.dart.
---

# tekartik_firebase apps and services

Platform-neutral Firebase core: `Firebase`/`FirebaseAsync` create and look up
`FirebaseApp` instances, `FirebaseAppOptions` configures them, and products
(auth, firestore, storage, functions) attach to an app through a
`FirebaseProductService`. No backend ships here: `tekartik_firebase_local`
(in-memory, tests), `tekartik_firebase_rest`, `tekartik_firebase_flutter`,
`tekartik_firebase_node` and `tekartik_firebase_admin_sdk` implement it.

## Guidelines

* Import `package:tekartik_firebase/firebase.dart` in app code.
  `package:tekartik_firebase/firebase_admin.dart` re-exports it plus the
  credential types; `package:tekartik_firebase/firebase_mixin.dart` is for
  backend and product implementers only. Never import
  `package:tekartik_firebase/src/...` (`src/firebase_mock.dart` is internal:
  use `tekartik_firebase_local` for tests).
* Never instantiate a `Firebase` in app code: take the getter of a backend
  package, each of which re-exports `firebase.dart`: `firebaseFlutter`
  (`package:tekartik_firebase_flutter/firebase_flutter.dart`), `firebaseRest`
  (`package:tekartik_firebase_rest/firebase_rest.dart`), `firebaseNode`
  (`package:tekartik_firebase_node/firebase_node.dart`), `firebaseAdminSdk`
  (`package:tekartik_firebase_admin_sdk/firebase_admin_sdk.dart`), or
  `newFirebaseMemory()` / `newFirebaseAppMemory()`
  (`package:tekartik_firebase_local/firebase_local.dart`) for tests and
  offline apps.
* Write shared code against `FirebaseAsync` and `FirebaseApp` and pass the app
  (or the product) as a parameter. `FirebaseApp.instance` is only the most
  recently initialized app of any backend: use it at most at the top level of
  a single-app program.
* Create an app once with `initializeApp(options:, name:)`; omit `name` for
  the default app (`firebaseAppNameDefault`, `'[DEFAULT]'`). Initializing the
  same name twice throws a `StateError` on most backends: retrieve it with
  `app(name:)` instead. `Firebase.apps` lists every live app of every backend
  in the process.
* Prefer `initializeAppAsync` / `appAsync` (the `FirebaseAsync` interface) in
  code that must also run on Flutter, where initialization is asynchronous.
  On the other backends they simply delegate to `initializeApp` / `app`.
* `FirebaseAppOptions` (alias `AppOptions`) fields (`apiKey`, `authDomain`,
  `databaseURL`, `projectId`, `storageBucket`, `messagingSenderId`, `appId`,
  `measurementId`) are mutable and nullable. Build it with the named
  constructor or `FirebaseAppOptions.fromMap` from decoded JSON and do not
  mutate it after `initializeApp`. Options can be omitted where the backend
  has defaults (Flutter, Node). Only log `toDebugMap()` / `toString()`: they
  keep `projectId` and an obfuscated `apiKey`. `app.projectId` (extension
  `TekartikFirebaseAppExt`) assumes the project id is set.
* Products are never created from the app: ask the product service of the
  chosen backend, e.g. `firestoreService.firestore(app)`,
  `authService.auth(app)`, `storageService.storage(app)`. The service caches
  one instance per app, registers itself with `app.addService` and the
  instance is also reachable with `app.getProduct<Firestore>()`. In-memory
  services accept any `FirebaseApp`, including a memory app:
  `firestoreServiceMemory` (`tekartik_firebase_firestore_sembast`),
  `authServiceLocal` (`tekartik_firebase_auth_local`), `storageServiceMemory`
  (`tekartik_firebase_storage_fs`).
* Always `await app.delete()` when done (tests: `tearDown`): it closes every
  registered service, disposes the products (`FirebaseAppProduct.dispose`)
  and removes the app from `Firebase.apps`. Do not keep products in globals
  across a `delete()`. Deleting the default app is refused by some backends.
* `app.isLocal` / `firebase.isLocal` tell whether the backend is in-memory
  (use it to skip tests that need a real project); `app.hasAdminCredentials`
  tells whether server-side (admin) operations are available.
* Admin (`firebase_admin.dart`): `FirebaseAdmin` adds `credential`, a
  `FirebaseAdminCredentialService`. `applicationDefault()` is resolved
  automatically on Node and Cloud Functions (`GOOGLE_APPLICATION_CREDENTIALS`);
  the REST backend needs `setApplicationDefault(credential)` before the app is
  initialized. `FirebaseAdminCredential.getAccessToken()` yields a
  `FirebaseAdminAccessToken` (`data`, `expiresIn`). Only node, admin_sdk and
  rest implement `FirebaseAdmin`.
* Implementing a backend: mix `FirebaseWithAppsMixin, FirebaseMixin` into the
  `Firebase` class (`initializeApp` calls `checkAppNameUninitialized(name)`
  then `addApp(app)`; `app()`, `initializeAppAsync` and `appAsync` come for
  free) and `FirebaseAppMixin` into the app class (override `name`, `options`
  and `firebase`; `delete()` closes the services then unregisters the app).
  Add `FirebaseAdminMixin` for admin backends. Override `isLocal` to `true`
  for in-memory backends. Validate it by calling `runFirebaseTests(firebase)`
  (`package:tekartik_firebase_test/firebase_test.dart`, dev dependency) inside
  a test `group`.
* Implementing a product: an abstract interface
  `implements FirebaseAppProduct<MyProduct>`, an implementation
  `with FirebaseAppProductMixin<MyProduct>` (provides `type`, `disposed` and
  `dispose()`, overrides must call `super.dispose()`), and a service
  `with FirebaseProductServiceMixin<MyProduct>` whose accessor calls
  `getInstance<MyProductImpl>(app, () => ...)`. Overrides of `init` / `close`
  must call `super`. `getExistingInstance` is `@visibleForTesting` only.

## Examples

### Initializing an app from any backend

```dart
import 'package:tekartik_firebase/firebase.dart';

/// [firebase]: firebaseFlutter, firebaseRest, firebaseNode or a memory one.
Future<FirebaseApp> initApp(
  FirebaseAsync firebase,
  Map<String, Object?> config,
) async {
  var options = FirebaseAppOptions.fromMap(config);
  // Equivalent: FirebaseAppOptions(apiKey: '...', projectId: '...')
  var app = await firebase.initializeAppAsync(options: options);
  print('app ${app.name} project ${app.projectId} local: ${app.isLocal}');
  return app;
}
```

### Test with a memory app and an attached product

```dart
import 'package:tekartik_firebase_firestore_sembast/firestore_sembast.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:test/test.dart';

void main() {
  late FirebaseApp app;
  late Firestore firestore;

  setUp(() {
    app = newFirebaseAppMemory(options: FirebaseAppOptions(projectId: 't'));
    firestore = firestoreServiceMemory.firestore(app);
  });
  tearDown(() => app.delete());

  test('product is cached per app', () {
    expect(app.isLocal, isTrue);
    expect(firestoreServiceMemory.firestore(app), same(firestore));
    expect(app.getProduct<Firestore>(), same(firestore));
  });
}
```

### Custom product service

```dart
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';

abstract class Counter implements FirebaseAppProduct<Counter> {
  int next();
}

class _CounterImpl with FirebaseAppProductMixin<Counter> implements Counter {
  @override
  final FirebaseApp app;
  var _value = 0;
  _CounterImpl(this.app);

  @override
  int next() => ++_value;
}

class CounterService with FirebaseProductServiceMixin<Counter> {
  /// One counter per app; disposed when the app is deleted.
  Counter counter(FirebaseApp app) =>
      getInstance<_CounterImpl>(app, () => _CounterImpl(app));
}
```

### Minimal backend built on the mixins

```dart
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';

class FirebaseFake with FirebaseWithAppsMixin, FirebaseMixin {
  @override
  bool get isLocal => true;

  @override
  FirebaseApp initializeApp({FirebaseAppOptions? options, String? name}) {
    name ??= firebaseAppNameDefault;
    checkAppNameUninitialized(name);
    options ??= FirebaseAppOptions(projectId: 'fake');
    return addApp(FirebaseAppFake(this, options, name));
  }
}

class FirebaseAppFake with FirebaseAppMixin {
  @override
  final FirebaseFake firebase;
  @override
  final FirebaseAppOptions options;
  @override
  final String name;
  FirebaseAppFake(this.firebase, this.options, this.name);
}
```
