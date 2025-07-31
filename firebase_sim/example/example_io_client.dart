import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_test/menu/firebase_client_menu.dart';

var urlKv = 'firebase_sim_example.url'.kvFromVar(
  defaultValue: 'ws://localhost:${firebaseSimDefaultPort.toString()}',
);

int? get urlKvPort => int.tryParse((urlKv.value ?? '').split(':').last);
Future<void> main(List<String> args) async {
  var firebase = getFirebaseSim(uri: Uri.parse(urlKv.value!));

  await mainMenu(args, () {
    firebaseMainMenu(context: FirebaseMainMenuContext(firebase: firebase));
    keyValuesMenu('kv', [urlKv]);
  });
}
