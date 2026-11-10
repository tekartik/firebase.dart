import 'package:tekartik_prefs_test/kv_store_test_runner.dart';
import 'package:test/test.dart';

/// Shared contract tests, reused across implementations.
void runTekartikFirebasePersistenceTests(KvStore Function() factory) {
  late KvStore persistence;
  setUp(() {
    persistence = factory();
  });
  test('missing key', () async {
    expect(await persistence.getString('missing'), isNull);
  });
  test('set/get/remove', () async {
    expect(await persistence.getString('key1'), isNull);
    await persistence.setString('key1', 'value1');
    expect(await persistence.getString('key1'), 'value1');
    await persistence.setString('key1', 'value2');
    expect(await persistence.getString('key1'), 'value2');
    await persistence.remove('key1');
    expect(await persistence.getString('key1'), isNull);
  });
  test('setStringOrNull null removes', () async {
    await persistence.setString('key1', 'value1');
    await persistence.setStringOrNull('key1', null);
    expect(await persistence.getString('key1'), isNull);
  });
  test('multiple keys', () async {
    await persistence.setString('key1', 'value1');
    await persistence.setString('key2', 'value2');
    expect(await persistence.getString('key1'), 'value1');
    expect(await persistence.getString('key2'), 'value2');
    await persistence.remove('key1');
    expect(await persistence.getString('key1'), isNull);
    expect(await persistence.getString('key2'), 'value2');
  });
  test('empty string value', () async {
    await persistence.setString('key1', '');
    expect(await persistence.getString('key1'), '');
  });
  test('empty and dot keys', () async {
    // The empty key first: as a file name it was the directory itself.
    var keys = ['', '.', '..', 'key1'];
    for (var key in keys) {
      await persistence.setString(key, 'value of "$key"');
    }
    for (var key in keys) {
      expect(await persistence.getString(key), 'value of "$key"');
    }
    for (var key in keys) {
      await persistence.remove(key);
      expect(await persistence.getString(key), isNull);
    }
  });

  group('kv_store', () {
    runKvStoreTests(factory());
  });
}
