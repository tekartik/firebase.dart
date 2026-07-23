Generic string key/value persistence, used as a building block for other
tekartik packages (credential storage, settings, ...).

Implementations:
- `TekartikFirebasePersistenceMemory`: in memory, for testing.
- `TekartikFirebasePersistenceFile`: file based (cross platform through
  `fs_shim`), one file per key.
- `TekartikFirebasePersistenceWeb`: web local storage based.
- `TekartikFirebasePersistenceSdb`: `idb_shim` sdb based, works on both io and
  web depending on the `SdbFactory` given (`sdbFactoryIo`, `sdbFactoryWeb`,
  `sdbFactoryMemory`...).

## Setup

```yaml
dependencies:
  tekartik_firebase_persistence:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_persistence
      version: '>=0.1.0'
```
