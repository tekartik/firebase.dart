import 'package:tekartik_firebase/utils/timestamp_utils.dart';
import 'package:test/test.dart';

bool get _runningAsJavascript => identical(1, 1.0);

main() {
  group('utils', () {
    test('DateTime', () {
      // DateTime cannot parse firestore timestamp
      var text = '2018-10-20T05:13:45.985343Z';
      expect(DateTime.tryParse(text), isNotNull);
    });
    test('parseTimestampString', () {
      var text = '2018-10-20T05:13:45.985343Z';
      var dateTime = dateTimeParseTimestamp(text);
      expect(dateTime.toIso8601String().substring(0, 23),
          '2018-10-20T05:13:45.985');
      expect(dateTime.toIso8601String().endsWith('Z'), isTrue);

      text = '2018-10-23T05:46:51.296391000Z';
      dateTime = dateTimeParseTimestamp(text);
      expect(dateTime.toIso8601String().substring(0, 23),
          '2018-10-23T05:46:51.296');
      expect(dateTime.toIso8601String().endsWith('Z'), isTrue);
    });

    test('dateTimeToTimestamp', () {
      var text = '2018-10-20T05:13:45.985000Z';
      var dateTime = dateTimeParseTimestamp(text);
      expect(dateTimeToTimestampMicros(dateTime), text);

      text = '2018-10-20T05:13:45.985343Z';
      dateTime = dateTimeParseTimestamp(text);
      if (_runningAsJavascript) {
        expect(
            dateTimeToTimestampMicros(dateTime), '2018-10-20T05:13:45.985000Z');
      } else {
        expect(dateTimeToTimestampMicros(dateTime), text);
      }
    });
  });
}
