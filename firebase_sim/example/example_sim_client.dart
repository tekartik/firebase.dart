import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_test/menu/firebase_client_menu.dart';

import 'vars_menu.dart';

Future<void> main(List<String> args) async {
  debugFirebaseSimClient = true;
  var firebase = getFirebaseSim(
    uri: getFirebaseSimLocalhostUri(port: simPortKvValue),
  );

  await mainMenu(args, () {
    firebaseMainMenu(
      context: FirebaseMainMenuContext(
        firebase: firebase,
        options: FirebaseAppOptions(projectId: 'firebase-sim-example'),
      ),
    );
    varsMenu();
  });
}
