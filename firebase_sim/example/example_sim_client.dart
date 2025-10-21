import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/src/firebase_sim.dart';
import 'package:tekartik_firebase_test/menu/firebase_client_menu.dart';

import 'vars_menu.dart';

Future<void> main(List<String> args) async {
  var firebase = getFirebaseSim(
    uri: getFirebaseSimLocalhostUri(port: simPortKvValue),
  );

  await mainMenu(args, () {
    firebaseMainMenu(context: FirebaseMainMenuContext(firebase: firebase));
    varsMenu();
  });
}
