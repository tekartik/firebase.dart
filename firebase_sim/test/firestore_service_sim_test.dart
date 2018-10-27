import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';
import 'package:test/test.dart';

main() {
  group("firestore_service_sim", () {
    test('supportsDocumentSnapshotTime', () {
      var firestoreService = FirestoreServiceSim();
      expect(firestoreService.supportsTimestampsInSnapshots, isFalse);
    });
  });
}
