import 'package:tekartik_firebase/src/firestore.dart';
import 'package:test/test.dart';

bool get _runningAsJavascript => identical(1, 1.0);

main() {
  group('utils', () {
    test('DateTime', () {
      // DateTime cannot parse firestore timestamp
      var text = '2018-10-20T05:13:45.985343Z';
      var dateTime = DateTime.tryParse(text);
      expect(dateTime, isNotNull);
      // VM: 2018-10-20T05:13:45.985343Z
      // Browser 2018-10-20T05:13:45.985Z
      // Node 2018-10-20T05:13:45.985Z
      expect(
          dateTime.toIso8601String(),
          _runningAsJavascript
              ? '2018-10-20T05:13:45.985Z'
              : '2018-10-20T05:13:45.985343Z');
      // print(dateTime.toIso8601String());

      text = '2018-10-20T05:13:45.985Z';
      dateTime = DateTime.tryParse(text);
      expect(dateTime, isNotNull);
      expect(dateTime.toIso8601String(), '2018-10-20T05:13:45.985Z');
      // 2018-10-20T05:13:45.985Z
      // print(dateTime.toIso8601String());

      text = '2018-10-20T05:13:45Z';
      dateTime = DateTime.tryParse(text);
      expect(dateTime, isNotNull);
      // 2018-10-20T05:13:45.000Z
      // print(dateTime.toIso8601String());

      text = '2018-10-20T05:13Z';
      dateTime = DateTime.tryParse(text);
      expect(dateTime, isNotNull);
      // 2018-10-20T05:13:00.000Z
      // print(dateTime.toIso8601String());

      text = '2018-10-20T05Z';
      dateTime = DateTime.tryParse(text);
      // expect(dateTime, isNotNull);
      // 2018-10-20T05:00:00.000Z
      print(dateTime.toIso8601String());

      text = '2018-10-20Z';
      dateTime = DateTime.tryParse(text);
      expect(dateTime, isNull);

      text = '2018-10-20';
      dateTime = DateTime.tryParse(text);
      expect(dateTime, isNotNull);
      // 2018-10-20T00:00:00.000
      print(dateTime.toIso8601String());

      text = '2018-10';
      dateTime = DateTime.tryParse(text);
      expect(dateTime, isNull);
      // 2018-10-20T00:00:00.000

      // Cannot parse this
      text = '2018-10-20T05:13:45.985343123Z';
      dateTime = DateTime.tryParse(text);
      expect(dateTime, isNull);
    });
    test('tryParse', () {
      var text = '2018-10-20T05:13:45.985Z';
      var timestamp = Timestamp.tryParse(text);
      expect(timestamp.toIso8601String(), '2018-10-20T05:13:45.985Z');

      text = '2018-10-20T05:13:45.985343Z';
      timestamp = Timestamp.tryParse(text);
      expect(timestamp.toIso8601String(), '2018-10-20T05:13:45.985343Z');

      text = '2018-10-20T05:13:45.985343123Z';
      timestamp = Timestamp.tryParse(text);
      expect(timestamp.toIso8601String(), '2018-10-20T05:13:45.985343Z');

      expect(Timestamp.tryParse('.123456789Z'), isNull);
      expect(Timestamp.tryParse('.123456Z'), isNull);
      expect(Timestamp.tryParse('.123Z'), isNull);

      text = '2018-10-20T05:13:45Z';
      timestamp = Timestamp.tryParse(text);
      expect(timestamp.toIso8601String(), '2018-10-20T05:13:45.000Z');

      text = '2018-10-20T01Z';
      timestamp = Timestamp.tryParse(text);
      expect(timestamp.toIso8601String(), '2018-10-20T01:00:00.000Z');
    });
  });
}
