import 'package:fs_shim/fs_memory.dart';
import 'package:idb_shim/sdb/sdb.dart';
import 'package:tekartik_firebase_persistence/firebase_persistence.dart';
import 'package:test/test.dart';

import 'src/persistence_test_runner.dart';

void main() {
  group('memory', () {
    runTekartikFirebasePersistenceTests(
      () => TekartikFirebasePersistenceMemory(),
    );
  });

  group('file (memory fs)', () {
    var index = 0;
    runTekartikFirebasePersistenceTests(
      () => TekartikFirebasePersistenceFile(
        fs: fileSystemMemory,
        directoryPath: 'test_persistence_${index++}',
      ),
    );

    test('key with special characters', () async {
      var persistence = TekartikFirebasePersistenceFile(
        fs: fileSystemMemory,
        directoryPath: 'test_persistence_special',
      );
      await persistence.setString('a/b c', 'value');
      expect(await persistence.getString('a/b c'), 'value');
    });
  });

  group('sdb (memory)', () {
    var index = 0;
    runTekartikFirebasePersistenceTests(
      () => TekartikFirebasePersistenceSdb(
        sdbFactory: sdbFactoryMemory,
        dbName: 'test_persistence_sdb_${index++}',
      ),
    );

    test('a failed open is not kept', () async {
      var dbName = 'test_persistence_sdb_failed_open';
      // A newer version of the app left the database at version 2.
      var db = await sdbFactoryMemory.openDatabase(
        dbName,
        options: SdbOpenDatabaseOptions(version: 2),
      );
      await db.close();
      var persistence = TekartikFirebasePersistenceSdb(
        sdbFactory: sdbFactoryMemory,
        dbName: dbName,
      );
      await expectLater(persistence.getString('key1'), throwsA(anything));

      // Once the database is deleted, the next call opens it again.
      await sdbFactoryMemory.deleteDatabase(dbName);
      await persistence.setString('key1', 'value1');
      expect(await persistence.getString('key1'), 'value1');
      await persistence.close();
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
