import 'package:tekartik_firebase_sim/rpc_message.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim_client.dart';

Map<String, dynamic> requestParams(Request request) =>
    request.params as Map<String, dynamic>;

Map<String, dynamic> notificationParams(Notification notification) =>
    notification.params as Map<String, dynamic>;

SimDocumentSnapshot snapshotsFindById(
    List<SimDocumentSnapshot> snapshots, String id) {
  for (var snapshot in snapshots) {
    if (snapshot.ref.id == id) {
      return snapshot;
    }
  }
  return null;
}
