import 'package:fs_shim/fs_shim.dart';
import 'package:fs_shim/utils/read_write.dart';
import 'package:idb_shim/sdb/sdb.dart';
import 'package:path/path.dart';
import 'package:tekartik_browser_utils/storage_utils.dart';
import 'package:tekartik_prefs/kv_store.dart';

/// Generic string key/value persistence.
///
/// Alias of [KvStore] from `package:tekartik_prefs/kv_store.dart`, which any
/// prefs implementation (memory, sembast, sdb, browser, flutter) also
/// implements.
@Deprecated('Use KvStore from package:tekartik_prefs/kv_store.dart')
typedef TekartikFirebasePersistence = KvStore;

/// Compat extension, on the former `get`/`set` api.
extension TekartikFirebasePersistenceExt on KvStore {
  /// Get the value associated to [key], null if not found.
  @Deprecated('Use getString')
  Future<String?> get(String key) => getString(key);

  /// Set the value associated to [key]. Set to null to remove it.
  @Deprecated('Use setString, remove, or setStringOrNull')
  Future<void> set(String key, String? value) => setStringOrNull(key, value);
}

/// In memory implementation.
class TekartikFirebasePersistenceMemory implements KvStore {
  final _map = <String, String>{};

  @override
  Future<String?> getString(String key) async => _map[key];

  @override
  Future<void> setString(String key, String value) async => _map[key] = value;

  @override
  Future<void> remove(String key) async => _map.remove(key);
}

/// Web local storage implementation.
class TekartikFirebasePersistenceWebLocalStorage implements KvStore {
  /// Prefix prepended to every key before hitting local storage.
  final String keyPrefix;

  /// Web local storage based persistence.
  TekartikFirebasePersistenceWebLocalStorage({this.keyPrefix = ''});

  String _key(String key) => '$keyPrefix$key';

  @override
  Future<String?> getString(String key) async {
    try {
      return webLocalStorageGet(_key(key));
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving $key from web storage: $e');
    }
    return null;
  }

  @override
  Future<void> setString(String key, String value) async {
    try {
      webLocalStorageSet(_key(key), value);
    } catch (e) {
      // ignore: avoid_print
      print('Error writing $key to web storage: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      webLocalStorageRemove(_key(key));
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting $key from web storage: $e');
    }
  }
}

/// File implementation (cross platform through fs_shim).
class TekartikFirebasePersistenceFile implements KvStore {
  /// The file system to use.
  final FileSystem fs;

  /// Directory where the files are saved.
  final String directoryPath;
  static const _directoryPathDefault = '.local';

  /// File system based persistence, one file per key in [directoryPath].
  TekartikFirebasePersistenceFile({
    /// Optional file system, default to [fileSystemDefault].
    FileSystem? fs,
    String? directoryPath,
  }) : fs = fs ?? fileSystemDefault,
       directoryPath = directoryPath ?? _directoryPathDefault;

  File _file(String key) =>
      fs.file(join(directoryPath, Uri.encodeComponent(key)));

  @override
  Future<String?> getString(String key) async {
    var file = _file(key);
    try {
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving $key from file storage: $e');
    }
    return null;
  }

  @override
  Future<void> setString(String key, String value) async {
    var file = _file(key);
    try {
      await writeString(file, value);
    } catch (e) {
      // ignore: avoid_print
      print('Error writing $key to file storage: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    var file = _file(key);
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting $key from file storage: $e');
    }
  }
}

/// Sdb (idb_shim) implementation, works both on io and web depending on the
/// [SdbFactory] used (for example `sdbFactoryIo` or `sdbFactoryWeb`).
class TekartikFirebasePersistenceSdb implements KvStore {
  /// The sdb factory used to open the database.
  final SdbFactory sdbFactory;

  /// The database name.
  final String dbName;
  static const _dbNameDefault = 'tekartik_firebase_persistence';
  static const _storeName = 'persistence';
  final _store = SdbStoreRef<String, String>(_storeName);

  Future<SdbDatabase>? _dbFuture;

  /// Sdb based persistence.
  TekartikFirebasePersistenceSdb({required this.sdbFactory, String? dbName})
    : dbName = dbName ?? _dbNameDefault;

  Future<SdbDatabase> _openDb() => _dbFuture ??= sdbFactory.openDatabase(
    dbName,
    options: SdbOpenDatabaseOptions(
      version: 1,
      schema: SdbDatabaseSchema(stores: [_store.schema()]),
    ),
  );

  @override
  Future<String?> getString(String key) async {
    var db = await _openDb();
    return await _store.record(key).getValue(db);
  }

  @override
  Future<void> setString(String key, String value) async {
    var db = await _openDb();
    await _store.record(key).put(db, value);
  }

  @override
  Future<void> remove(String key) async {
    var db = await _openDb();
    await _store.record(key).delete(db);
  }

  /// Close the underlying database.
  Future<void> close() async {
    var dbFuture = _dbFuture;
    if (dbFuture != null) {
      _dbFuture = null;
      await (await dbFuture).close();
    }
  }
}
