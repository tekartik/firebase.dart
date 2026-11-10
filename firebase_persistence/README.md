# tekartik_firebase_persistence

Small async string key/value stores (`KvStore`: `getString`, `setString`, a
null value removing the key) in memory, in files, in web local storage or in
an sdb database. The
REST auth packages use them to cache credentials. Despite its name the package
does not depend on Firebase.

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_firebase_persistence:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_persistence
    version: '>=0.3.0'
```

```dart
import 'package:tekartik_firebase_persistence/firebase_persistence.dart';

Future<void> main() async {
  // One file per key in .local (Dart VM, Flutter desktop).
  KvStore store = TekartikFirebasePersistenceFile(directoryPath: '.local/my_app');
  await store.setString('token', '{"access":"abc"}');
  print(await store.getString('token')); // {"access":"abc"}
  await store.remove('token');
}
```

Runnable: [example/main.dart](example/main.dart).

## Which store

| Class | Platform | Storage |
|---|---|---|
| `TekartikFirebasePersistenceMemory()` | any | memory, lost when the process ends (tests) |
| `TekartikFirebasePersistenceFile({fs, directoryPath})` | Dart VM, Flutter desktop / mobile (any `fs_shim` file system) | one file per key in `directoryPath` (default `.local`, relative to the current directory) |
| `TekartikFirebasePersistenceWebLocalStorage({keyPrefix})` | web | `window.localStorage`, keys prefixed by `keyPrefix` |
| `TekartikFirebasePersistenceSdb({sdbFactory, dbName})` | web (`sdbFactoryWeb`), Dart VM (`sdbFactoryIo`), tests (`sdbFactoryMemory`) | one store `persistence` in the sdb database `dbName` (default `tekartik_firebase_persistence`) |

Write your APIs against `KvStore` (re-exported here from `tekartik_prefs`): any
`PrefsLight` of `tekartik_prefs_*` gives a `KvStore` too (`prefs.kvStore`).

## Common pitfalls

* Values are strings: `jsonEncode` what you store, keep it small (credentials,
  settings). Application data belongs in a database (sdb).
* The file and web local storage stores catch and print their errors: a failed
  write is lost silently and `getString` returns null. The sdb store throws.
* File store: the file name is `Uri.encodeComponent(key)`. On a case
  insensitive file system (macOS, Windows) `Token` and `token` are one file;
  avoid `*` and a trailing `.` in keys on Windows.
* Sdb store: the database opens on first use (a failed open is tried again at
  the next call); `close()` it when done, the next call reopens it.
* `TekartikFirebasePersistence` and its `get` / `set` are deprecated: use
  `KvStore` and `getString` / `setString` (a null value removes the key) /
  `remove`.

Agent skill: [skills/tekartik-firebase-persistence-kvstore](skills/tekartik-firebase-persistence-kvstore/SKILL.md).
