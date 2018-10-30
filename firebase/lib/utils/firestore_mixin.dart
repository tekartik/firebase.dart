import 'package:tekartik_firebase/firestore.dart';

// might evolve to be always true
bool firestoreTimestampsInSnapshots(Firestore firestore) {
  if (firestore is FirestoreMixin) {
    return (firestore as FirestoreMixin)
            .firestoreSettings
            ?.timestampsInSnapshots ==
        true;
  }
  return false;
}

class FirestoreMixin {
  FirestoreSettings firestoreSettings;
}
