library;

export 'package:tekartik_prefs/kv_store.dart'
    show
        KvStore,
        KvStoreExt,
        KvStoreRead,
        KvStoreWrite,
        KvStoreGetStringFunction,
        KvStoreSetStringFunction,
        KvStoreRemoveFunction;

export 'src/firebase_persistence.dart'
    show
        // ignore: deprecated_member_use_from_same_package
        TekartikFirebasePersistence,
        TekartikFirebasePersistenceExt,
        TekartikFirebasePersistenceMemory,
        TekartikFirebasePersistenceWebLocalStorage,
        TekartikFirebasePersistenceFile,
        TekartikFirebasePersistenceSdb;
