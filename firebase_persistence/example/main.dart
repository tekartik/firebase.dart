// ignore_for_file: avoid_print
import 'package:fs_shim/fs_memory.dart';
import 'package:idb_shim/sdb/sdb.dart';
import 'package:tekartik_firebase_persistence/firebase_persistence.dart';

/// Works with any [KvStore].
Future<void> saveAndRead(String name, KvStore store) async {
  await store.setString('theme', 'dark');
  print('$name: ${await store.getString('theme')}');
  // A null value removes the key, as remove(key) does.
  await store.setString('theme', null);
  print('$name after remove: ${await store.getString('theme')}');
}

Future<void> main() async {
  await saveAndRead('memory', TekartikFirebasePersistenceMemory());

  // Files through fs_shim: fileSystemDefault (io) by default, here in memory.
  await saveAndRead(
    'file',
    TekartikFirebasePersistenceFile(
      fs: newFileSystemMemory(),
      directoryPath: '.local/example',
    ),
  );

  // sdb: sdbFactoryWeb on the web, sdbFactoryIo on the Dart VM.
  var sdbStore = TekartikFirebasePersistenceSdb(
    sdbFactory: newSdbFactoryMemory(),
    dbName: 'example_settings',
  );
  await saveAndRead('sdb', sdbStore);
  await sdbStore.close();
}
