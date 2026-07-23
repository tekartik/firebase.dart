import 'package:fs_shim/fs_shim.dart';
import 'package:fs_shim/utils/read_write.dart';
import 'package:idb_shim/sdb/sdb.dart';
import 'package:path/path.dart';
import 'package:tekartik_browser_utils/storage_utils.dart';

/// Generic string key/value persistence.
abstract class TekartikFirebasePersistence {
  /// Get the value associated to [key], null if not found.
  Future<String?> get(String key);

  /// Set the value associated to [key]. Set to null to remove it.
  Future<void> set(String key, String? value);
}

/// Persistence extension
extension TekartikFirebasePersistenceExt on TekartikFirebasePersistence {
  /// Remove the value associated to [key].
  Future<void> remove(String key) => set(key, null);
}

/// In memory implementation.
class TekartikFirebasePersistenceMemory implements TekartikFirebasePersistence {
  final _map = <String, String>{};

  @override
  Future<String?> get(String key) async => _map[key];

  @override
  Future<void> set(String key, String? value) async {
    if (value == null) {
      _map.remove(key);
    } else {
      _map[key] = value;
    }
  }
}

/// Web local storage implementation.
class TekartikFirebasePersistenceWebLocalStorage
    implements TekartikFirebasePersistence {
  /// Prefix prepended to every key before hitting local storage.
  final String keyPrefix;

  /// Web local storage based persistence.
  TekartikFirebasePersistenceWebLocalStorage({this.keyPrefix = ''});

  String _key(String key) => '$keyPrefix$key';

  @override
  Future<String?> get(String key) async {
    try {
      return webLocalStorageGet(_key(key));
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving $key from web storage: $e');
    }
    return null;
  }

  @override
  Future<void> set(String key, String? value) async {
    var storageKey = _key(key);
    if (value == null) {
      webLocalStorageRemove(storageKey);
    } else {
      webLocalStorageSet(storageKey, value);
    }
  }
}

/// File implementation (cross platform through fs_shim).
class TekartikFirebasePersistenceFile implements TekartikFirebasePersistence {
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
  Future<String?> get(String key) async {
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
  Future<void> set(String key, String? value) async {
    var file = _file(key);
    if (value == null) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error deleting $key from file storage: $e');
      }
    } else {
      try {
        await writeString(file, value);
      } catch (e) {
        // ignore: avoid_print
        print('Error writing $key to file storage: $e');
      }
    }
  }
}

/// Sdb (idb_shim) implementation, works both on io and web depending on the
/// [SdbFactory] used (for example `sdbFactoryIo` or `sdbFactoryWeb`).
class TekartikFirebasePersistenceSdb implements TekartikFirebasePersistence {
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
  Future<String?> get(String key) async {
    var db = await _openDb();
    return await _store.record(key).getValue(db);
  }

  @override
  Future<void> set(String key, String? value) async {
    var db = await _openDb();
    var record = _store.record(key);
    if (value == null) {
      await record.delete(db);
    } else {
      await record.put(db, value);
    }
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
