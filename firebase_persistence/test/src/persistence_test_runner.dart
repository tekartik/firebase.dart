import 'package:tekartik_firebase_persistence/firebase_persistence.dart';
import 'package:test/test.dart';

/// Shared contract tests, reused across implementations.
void runTekartikFirebasePersistenceTests(
  TekartikFirebasePersistence Function() factory,
) {
  late TekartikFirebasePersistence persistence;
  setUp(() {
    persistence = factory();
  });
  test('missing key', () async {
    expect(await persistence.get('missing'), isNull);
  });
  test('set/get/remove', () async {
    expect(await persistence.get('key1'), isNull);
    await persistence.set('key1', 'value1');
    expect(await persistence.get('key1'), 'value1');
    await persistence.set('key1', 'value2');
    expect(await persistence.get('key1'), 'value2');
    await persistence.remove('key1');
    expect(await persistence.get('key1'), isNull);
  });
  test('set null removes', () async {
    await persistence.set('key1', 'value1');
    await persistence.set('key1', null);
    expect(await persistence.get('key1'), isNull);
  });
  test('multiple keys', () async {
    await persistence.set('key1', 'value1');
    await persistence.set('key2', 'value2');
    expect(await persistence.get('key1'), 'value1');
    expect(await persistence.get('key2'), 'value2');
    await persistence.remove('key1');
    expect(await persistence.get('key1'), isNull);
    expect(await persistence.get('key2'), 'value2');
  });
  test('empty string value', () async {
    await persistence.set('key1', '');
    expect(await persistence.get('key1'), '');
  });
}
