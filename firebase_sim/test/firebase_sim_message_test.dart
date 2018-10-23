import 'package:test/test.dart';
import 'package:tekartik_firebase_sim/firebase_sim_message.dart';

main() {
  group("message", () {
    test('DocumentSnapshotData', () {
      var snapshotData = DocumentSnapshotData.fromMessageMap({
        'path': 'path',
        'data': {'test': 1},
        'createTime': '1',
        'updateTime': '2'
      });
      expect(snapshotData.toMap(), {
        'path': 'path',
        'data': {'test': 1},
        'createTime': '1',
        'updateTime': '2'
      });
    });
  });
}
