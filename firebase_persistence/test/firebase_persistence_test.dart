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
      await persistence.set('a/b c', 'value');
      expect(await persistence.get('a/b c'), 'value');
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
  });
}
