import 'package:tekartik_app_dev_menu/dev_menu.dart';

int? get simPortKvValue {
  return int.tryParse(simPortKv.value ?? '');
}

var simPortKv = 'firebase_sim_example.sim.port'.kvFromVar();

void varsMenu() {
  keyValuesMenu('vars', [simPortKv]);
}

Future<void> main(List<String> args) async {
  await mainMenu(args, () {
    varsMenu();
  });
}
