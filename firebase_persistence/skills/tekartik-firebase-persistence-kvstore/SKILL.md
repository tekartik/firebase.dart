---
name: tekartik-firebase-persistence-kvstore
description: >-
  Use when a Dart/Flutter package or app needs a small async string key/value
  store (cached OAuth/Firebase REST credentials, tokens, a few settings) that
  works in memory, on the file system, in web local storage or in an sdb
  database, with tekartik_firebase_persistence: choosing between
  TekartikFirebasePersistenceMemory/File/WebLocalStorage/Sdb, depending on the
  KvStore interface, and plugging a store into tekartik_firebase_auth_rest or
  tekartik_google_auth_io.
---

# tekartik_firebase_persistence key/value stores

Ready-made implementations of `KvStore` (`getString`, `setString`, `remove`),
the minimal async string key/value interface of `tekartik_prefs`. Despite the
name the package does not depend on `tekartik_firebase`: it is the storage
building block used by the REST auth packages to cache credentials.

## Guidelines

* Import only `package:tekartik_firebase_persistence/firebase_persistence.dart`.
  It re-exports `KvStore`, `KvStoreRead`, `KvStoreWrite`, `KvStoreExt` and the
  function typedefs from `package:tekartik_prefs/kv_store.dart`.
* Depend on `KvStore` in your APIs and constructors, never on a concrete
  `TekartikFirebasePersistence*` class. Callers then choose the backend, and any
  `PrefsLight` (`tekartik_prefs_sembast`, `tekartik_prefs_sdb`,
  `tekartik_prefs_browser`, `tekartik_prefs_flutter`) can be passed directly
  since `PrefsLight implements KvStore`.
* Use `getString`/`setString`/`remove` and `setStringOrNull` (from
  `KvStoreExt`). Do not use the deprecated `TekartikFirebasePersistence` alias
  nor the deprecated `get`/`set` methods of `TekartikFirebasePersistenceExt`.
* Values are strings only: serialize with `jsonEncode`/`jsonDecode` (or
  `cvToJson`/`jsonToMap` from `cv`) and keep it to small payloads such as
  credentials or settings. Application data belongs in sembast/sdb.
* Namespace your keys with a constant prefix (the REST auth uses
  `tekartik_firebase_auth_rest_access_credentials_<projectId>`) so several
  features can share one store.
* Pick the implementation by platform:
  * `TekartikFirebasePersistenceMemory()`: tests and sign-ins that must not
    survive the process.
  * `TekartikFirebasePersistenceFile({fs, directoryPath})`: CLI/desktop, one
    file per key (`Uri.encodeComponent(key)`) in `directoryPath`, default
    `.local` relative to the current directory (gitignore it). `fs` defaults to
    `fileSystemDefault`; pass `fileSystemMemory` (`fs_shim`) in tests.
  * `TekartikFirebasePersistenceWebLocalStorage({keyPrefix})`: browser only;
    set `keyPrefix` to isolate apps sharing an origin.
  * `TekartikFirebasePersistenceSdb({sdbFactory, dbName})`: same code on io
    and web, choose `sdbFactoryIo`, `sdbFactoryWeb` or `sdbFactoryMemory` from
    `package:idb_shim/sdb/sdb.dart` (`sdbFactoryIo.sandbox(path:)` in tests).
    The database (default name `tekartik_firebase_persistence`, one store
    `persistence`) opens lazily on first use; call `close()` when done, the
    next call reopens it.
* Error handling differs: the file and web local storage stores catch and
  `print` errors (`getString` returns null), the sdb store lets them throw.
* To adapt an existing storage without a class, use the `KvStore` factory
  constructor: `KvStore(getString: ..., setString: ..., remove: ...)`.
* Prefer these stores over hand-written credential files in the consumers:
  `FirebaseRestAuthPersistenceOnPersistence(KvStore)` and
  `GoogleAuthProviderRestIo(credentialsPersistence:, credentialsKey:)` in
  `tekartik_firebase_auth_rest`, `TekartikGoogleAuthOptionsIo(
  credentialsPersistence:, credentialsKey:)` in `tekartik_google_auth_io`. Both
  re-export the four implementations, so no extra import is needed there.
* Test a new `KvStore` implementation with `runKvStoreTests(store)` from
  `package:tekartik_prefs_test/kv_store_test_runner.dart`.
* This is not a Firestore/Firebase offline persistence layer: for Firestore use
  `tekartik_firebase_firestore`, for prefs with typed values use
  `tekartik_prefs`.

## Examples

### Depend on `KvStore`, store JSON

```dart
import 'dart:convert';

import 'package:tekartik_firebase_persistence/firebase_persistence.dart';

const _tokenKeyPrefix = 'my_app_token_';

/// Caches a token per account in any [KvStore].
class TokenCache {
  final KvStore store;
  TokenCache(this.store);

  Future<Map<String, Object?>?> read(String account) async {
    var raw = await store.getString('$_tokenKeyPrefix$account');
    return raw == null ? null : (jsonDecode(raw) as Map).cast<String, Object?>();
  }

  Future<void> write(String account, Map<String, Object?>? token) =>
      store.setStringOrNull(
        '$_tokenKeyPrefix$account',
        token == null ? null : jsonEncode(token),
      );
}

// Production (CLI): TokenCache(TekartikFirebasePersistenceFile(directoryPath: '.local/my_app'));
// Tests: TokenCache(TekartikFirebasePersistenceMemory());
```

### Sdb store shared by io and web

```dart
import 'package:idb_shim/sdb/sdb.dart';
import 'package:tekartik_firebase_persistence/firebase_persistence.dart';

/// Pass `sdbFactoryIo` on io, `sdbFactoryWeb` on web, `sdbFactoryMemory` in tests.
Future<void> demo(SdbFactory sdbFactory) async {
  var store = TekartikFirebasePersistenceSdb(
    sdbFactory: sdbFactory,
    dbName: 'my_app_settings',
  );
  await store.setString('theme', 'dark');
  print(await store.getString('theme')); // dark
  await store.remove('theme');
  await store.close();
}
```

### Credential cache for a Google/Firebase REST sign-in

```dart
import 'package:tekartik_firebase_persistence/firebase_persistence.dart';
import 'package:tekartik_google_auth_io/google_auth_io.dart';

/// Mutable so tests can swap in a [TekartikFirebasePersistenceMemory].
KvStore credentialsPersistence = TekartikFirebasePersistenceFile(
  directoryPath: '.local/my_app',
);

TekartikGoogleAuthOptionsIo buildOptions({
  required String clientId,
  required String clientSecret,
}) => TekartikGoogleAuthOptionsIo(
  clientId: clientId,
  clientSecret: clientSecret,
  credentialsPersistence: credentialsPersistence,
  // One key per account to keep several sign-ins side by side.
  credentialsKey: 'access_credentials_dev.yaml',
);
```
