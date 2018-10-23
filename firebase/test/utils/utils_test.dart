import 'package:tekartik_firebase/utils/timestamp_utils.dart';
import 'package:test/test.dart';

main() {
  group('utils', () {
    test('mapCreateTime', () {
      expect(mapCreateTime(null), isNull);
      expect(mapCreateTime({}).toIso8601String(), '2018-10-23T00:00:00.000Z');
    });
  });
}
