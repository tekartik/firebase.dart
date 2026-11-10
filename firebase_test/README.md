# tekartik_firebase_test

The shared tests every `tekartik_firebase` implementation runs (local, sim,
rest, node, admin sdk, flutter): app initialization, lookup, options,
products and deletion through the public API only, plus a console dev menu
and a CI helper. Pure Dart on `package:test`.

## Getting started

Git package, not on pub.dev, used as a dev dependency of the implementation
it tests:

```yaml
dev_dependencies:
  tekartik_firebase_test:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_test
  test: '>=1.31.0'
```

The suite on the in memory local implementation
(`test/firebase_memory_test.dart`):

```dart
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:test/test.dart';

void main() {
  group('memory', () {
    runFirebaseTests(
      newFirebaseMemory(),
      options: AppOptions(projectId: 'my-project'),
    );
  });
}
```

Run it with `dart test`.

## What it checks

`runFirebaseTests(firebase, options:, name:)` initializes an app
(`initializeAppAsync`), then checks that it is in `Firebase.apps`, its name
(`name` or `[DEFAULT]`) and project id, that `app(name:)` and
`appAsync(name:)` return the same app instance (with its products), the
product registration (`addService`, `getProduct`, `dispose`), that a deleted
app leaves `Firebase.apps` and that its name can be initialized again. The app
is deleted at the end.

`runFirebaseAppTests` and `runFirebaseAppProductTests` (in
`firebase_app_test.dart` and `firebase_product_test.dart`) run parts of it on
an app you own.

## What to know

* Wrap each call in its own `group()`: two calls in one file otherwise share
  their test names and set up both apps before any test.
* `ci_shell_io.dart` (io only) is for the `run_ci.dart` scripts of the
  workflows running the tests that need a service account
  (`firebaseGithubActionEnvTestShell`).
* `menu/firebase_client_menu.dart` is a
  [`tekartik_app_dev_menu`](https://github.com/tekartik/app_common_utils.dart)
  console menu to initialize, inspect and delete apps by hand.

More in the [package skill](skills/tekartik-firebase-test-suite/SKILL.md).
