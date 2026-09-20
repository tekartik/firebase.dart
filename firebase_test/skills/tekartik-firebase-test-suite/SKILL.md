---
name: tekartik-firebase-test-suite
description: >-
  Use when validating a tekartik_firebase implementation (local, sim, rest,
  node, admin sdk, flutter, or your own backend) against the shared contract
  test suite of tekartik_firebase_test: runFirebaseTests, runFirebaseAppTests,
  runFirebaseAppProductTests, the FirebaseProductServiceMock /
  FirebaseAppProductMock fixtures, the interactive firebaseMainMenu /
  FirebaseMainMenuContext dev menu, and firebaseGithubActionEnvTestShell /
  githubActionsEnvTestEnvKey for the CI workflows that run credential-dependent
  env tests.
---

# Shared Firebase contract tests (tekartik_firebase_test)

`tekartik_firebase_test` holds the implementation-agnostic `package:test` suites
that every `tekartik_firebase` backend runs against itself. Depend on it from a
backend package (or from an app that wraps one) and call `runFirebaseTests`
with your `Firebase` instance: the suite exercises app initialization, lookup,
options, products and deletion through the public interface only.

## Guidelines

* Dependency (git, not on pub.dev) — always a **dev** dependency, it pulls
  `package:test`:
  ```yaml
  dev_dependencies:
    tekartik_firebase_test:
      git:
        url: https://github.com/tekartik/firebase.dart
        path: firebase_test
  ```
* Four public libraries: `package:tekartik_firebase_test/firebase_test.dart`
  (`runFirebaseTests`, and it re-exports
  `package:tekartik_firebase/firebase.dart`, so `Firebase`, `FirebaseApp`,
  `AppOptions` need no second import), `firebase_app_test.dart`
  (`runFirebaseAppTests`), `firebase_product_test.dart`
  (`runFirebaseAppProductTests` + the mock product fixtures),
  `menu/firebase_client_menu.dart` (interactive dev menu) and
  `ci_shell_io.dart` (CI helper, `dart:io` only). There is no `lib/src`.
* `runFirebaseTests(firebaseAsync, {options, name})` takes a `FirebaseAsync`
  (every `Firebase` is one) and registers, in the current group:
  a `setUpAll` doing `initializeAppAsync(options: options, name: name)` and
  asserting the app is in `Firebase.apps`, `runFirebaseAppTests`,
  `runFirebaseAppProductTests`, an `apps` / `default app name` /`reinit` group
  and a `tearDownAll` deleting the app.
* Consequences to check before calling it on a new backend: the implementation
  must support `initializeAppAsync`, `appAsync(name:)`, registering in
  `Firebase.apps`, `app.delete()` **and re-initializing the same name after a
  delete** (the `reinit` test), plus `app.addService` / `getProduct` (the
  product group). `app.name` must be `name` or `'[DEFAULT]'` when `name` is
  null, and `app.options.projectId` must survive a lookup.
* Pass `options: null` explicitly for backends that get their options from the
  environment (node, admin sdk, Flutter); pass
  `AppOptions(projectId: ...)` when the backend needs a project id (rest, sim).
* Wrap each call in its own `group('<impl>', () { ... })` when a single test
  file validates several implementations or several option sets, otherwise the
  test names collide. Call it from `main()` (or from a `Future main()` after
  the async setup of the backend), never inside `setUp`.
* Compose a narrower suite with `runFirebaseAppTests(firebaseAsync, () => app)`
  and `runFirebaseAppProductTests(firebaseAsync, () => app)` when you own the
  app lifecycle (e.g. an app that must not be deleted). The second argument is
  a getter, called at test time, so an app created in `setUpAll` is fine.
* `firebase_product_test.dart` also exports reusable fixtures for testing
  product plumbing yourself: `FirebaseProductServiceMock` (a
  `FirebaseProductServiceMixin` with an `initCount` and a `product(app)`
  method), `FirebaseAppProductMock` / `FirebaseAppProductMockBase` and
  `FirebaseAppOptionsMock`.
* `runApp(...)` is deprecated, use `runFirebaseTests`.
* Interactive debugging: `menu/firebase_client_menu.dart` exposes
  `firebaseMainMenu(context: FirebaseMainMenuContext(firebase:, options:))`,
  an `app` menu with `initializeApp`, `initializeAppAsync`, `delete` and
  `properties` items, and re-exports `tekartik_app_dev_menu`
  (`mainMenu`, `menu`, `item`, `write`). Use it in `example/`, never in tests.
* CI: `ci_shell_io.dart` (io only) provides
  `firebaseGithubActionEnvTestShell(path, {flag})`, a `process_run` `Shell`
  rooted at `path` with `TEKARTIK_GITHUB_ACTIONS_ENV_TEST=true`
  (`githubActionsEnvTestEnvKey`) in its environment, and reading `path`'s own
  environment (`.local/ds_env.yaml`). It is for the
  `repo_support/workflow_ci_<name>_test/tool/run_ci.dart` scripts that run the
  tests needing a private service account; the test side skips them unless the
  variable is set.

## Examples

### Run the whole suite against an implementation

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

void main() {
  group('local', () {
    runFirebaseTests(FirebaseLocal(localPath: '.dart_tool/firebase_local'));
  });
  group('memory', () {
    runFirebaseTests(
      newFirebaseMemory(),
      options: AppOptions(projectId: 'my-project'),
    );
  });
}
```

### Async backend setup, and a named app

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  // e.g. start a server/emulator, read credentials... before defining tests.
  var firebase = newFirebaseMemory();

  group('my_backend', () {
    runFirebaseTests(
      firebase,
      options: AppOptions(projectId: 'my-project'),
      name: 'my_app',
    );
  });
}
```

### Own the app lifecycle, run only the app and product suites

```dart
@TestOn('vm')
library;

import 'package:tekartik_firebase_test/firebase_app_test.dart';
import 'package:tekartik_firebase_test/firebase_product_test.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:test/test.dart';

void main() {
  var firebase = newFirebaseMemory();
  late FirebaseApp app;

  setUpAll(() async {
    app = await firebase.initializeAppAsync(
      options: AppOptions(projectId: 'my-project'),
    );
  });
  tearDownAll(() async {
    await app.delete();
  });

  runFirebaseAppTests(firebase, () => app);
  runFirebaseAppProductTests(firebase, () => app);

  test('own service', () async {
    var service = FirebaseProductServiceMock();
    await app.addService(service);
    expect(service.initCount, 1);
    expect(app.getProduct<FirebaseAppProductMockBase>(), isNull);
    expect(service.product(app), isNotNull);
  });
}
```

### Interactive menu in example/

```dart
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/menu/firebase_client_menu.dart';

Future<void> main(List<String> args) async {
  await mainMenu(args, () {
    firebaseMainMenu(
      context: FirebaseMainMenuContext(
        firebase: newFirebaseMemory(),
        options: FirebaseAppOptions(projectId: 'my-project'),
      ),
    );
  });
}
```

### CI script for the credential-dependent tests

```dart
import 'package:path/path.dart';
import 'package:tekartik_firebase_test/ci_shell_io.dart';

Future<void> main() async {
  var path = join('..', '..', 'firebase_rest');
  var shell = firebaseGithubActionEnvTestShell(path);
  await shell.run('dart test test/firebase_rest_env_io_test.dart');
}
```

## Common mistakes

* Putting `tekartik_firebase_test` in `dependencies`: it is a dev/test-only
  package.
* Calling `runFirebaseTests` on a backend whose app cannot be deleted and
  re-created under the same name: the `reinit` test fails.
* Creating the app yourself and also calling `runFirebaseTests`, which creates
  and deletes its own app; use `runFirebaseAppTests` /
  `runFirebaseAppProductTests` instead.
* Forgetting `@TestOn('vm')` on a suite whose backend is io only.
* Importing `ci_shell_io.dart` from a web-compiled file (`dart:io`).
