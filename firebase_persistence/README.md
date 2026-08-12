`KvStore` implementations, used as a building block for other tekartik packages
(credential storage, settings, ...).

The interface itself is `KvStore` from
[`tekartik_prefs`](https://github.com/tekartik/prefs.dart/tree/main/prefs)
(`getString`, `setString`, `remove`), re-exported here. `PrefsLight` implements
it too, so any prefs (sembast, sdb, browser, flutter) can be used where these
implementations are expected.

Implementations:
- `TekartikFirebasePersistenceMemory`: in memory, for testing.
- `TekartikFirebasePersistenceFile`: file based (cross platform through
  `fs_shim`), one file per key.
- `TekartikFirebasePersistenceWebLocalStorage`: web local storage based.
- `TekartikFirebasePersistenceSdb`: `idb_shim` sdb based, works on both io and
  web depending on the `SdbFactory` given (`sdbFactoryIo`, `sdbFactoryWeb`,
  `sdbFactoryMemory`...).

`TekartikFirebasePersistence` is a deprecated alias of `KvStore`, and its
`get`/`set` methods are deprecated in favor of `getString`/`setString`/`remove`
(`setStringOrNull` replaces `set(key, null)`).

## Setup

```yaml
dependencies:
  tekartik_firebase_persistence:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_persistence
      version: '>=0.2.0'
```
