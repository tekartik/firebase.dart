@TestOn('browser')
library;

import 'package:idb_shim/sdb/sdb.dart';
import 'package:tekartik_firebase_persistence/firebase_persistence.dart';
import 'package:test/test.dart';

import 'src/persistence_test_runner.dart';

void main() {
  group('web (local storage)', () {
    var index = 0;
    runTekartikFirebasePersistenceTests(
      () => TekartikFirebasePersistenceWebLocalStorage(
        keyPrefix: 'tekartik_firebase_persistence_test_${index++}_',
      ),
    );
  });

  group('sdb (web)', () {
    var sandbox = sdbFactoryWeb.sandbox(
      path: 'tekartik_firebase_persistence_test',
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
