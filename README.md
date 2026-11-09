# firebase.dart

Platform neutral Firebase for Dart: the same app code runs on Flutter, the Dart
VM, the browser and node, only the backend changes. A pub workspace.

| Package | Folder | What |
|---|---|---|
| `tekartik_firebase` | [`firebase/`](firebase) | The core: `Firebase`, `FirebaseApp`, `FirebaseAppOptions`, product services. Start with its [README](firebase/README.md). |
| `tekartik_firebase_local` | [`firebase_local/`](firebase_local) | In memory (or local) backend, for tests and offline tools: `newFirebaseMemory()`. |
| `tekartik_firebase_test` | [`firebase_test/`](firebase_test) | Shared test suite for a backend: `runFirebaseTests(firebase)`. |
| `tekartik_firebase_sim` | [`firebase_sim/`](firebase_sim) | Firebase simulation over a web socket. |
| `tekartik_firebase_persistence` | [`firebase_persistence/`](firebase_persistence) | String key/value persistence (memory, file, web local storage, sdb). |

The other backends and the products (auth, firestore, storage, functions) live
in their own repositories, listed in the
[tekartik_firebase README](firebase/README.md#backends).

## Getting started

Git packages, not on pub.dev:

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
  var app = newFirebaseAppMemory(
    options: FirebaseAppOptions(projectId: 'my-project'),
  );
  print(app.projectId); // my-project
  await app.delete();
}
```

## Testing

```bash
# from a package folder
dart test
```
