@TestOn('vm')
library;

import 'package:idb_shim/sdb/sdb.dart';
import 'package:path/path.dart';
import 'package:tekartik_firebase_persistence/firebase_persistence.dart';
import 'package:test/test.dart';

import 'src/persistence_test_runner.dart';

void main() {
  group('file (io)', () {
    var index = 0;
    runTekartikFirebasePersistenceTests(
      () => TekartikFirebasePersistenceFile(
        directoryPath: join(
          '.dart_tool',
          'tekartik_firebase_persistence_test',
          'file_${index++}',
        ),
      ),
    );
  });

  group('sdb (io)', () {
    var sandbox = sdbFactoryIo.sandbox(
      path: join('.dart_tool', 'tekartik_firebase_persistence_test', 'sdb'),
    );
    var index = 0;
    runTekartikFirebasePersistenceTests(
      () => TekartikFirebasePersistenceSdb(
        sdbFactory: sandbox,
        dbName: 'test_${index++}',
      ),
    );
  });
}
