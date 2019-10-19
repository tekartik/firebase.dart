import 'package:process_run/shell.dart';
import 'package:process_run/which.dart';
import 'package:tekartik_build_utils/android/android_import.dart';

Future main() async {
  var shell = Shell();

  bool hasNode = whichSync('npm') != null;
  // Has node
  if (hasNode) {
    if (!Directory('node_modules').existsSync()) {
      await shell.run('npm install');
    }
  }
  await shell.run('''
dartanalyzer --fatal-warnings --fatal-infos lib test tool
dartfmt -n --set-exit-if-changed .
''');

  if (hasNode) {
    await shell.run('pub run test -p vm,node');
  }
}
