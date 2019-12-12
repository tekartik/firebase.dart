import 'package:process_run/shell.dart';
import 'package:process_run/which.dart';

Future main() async {
  var shell = Shell();

  for (var dir in [
    'firebase_rest',
    'firebase',
    'firebase_browser',
    'firebase_node',
    'firebase_sim',
    'firebase_sim_browser',
    'firebase_sim_io',
    'firebase_test',
  ]) {
    shell = shell.pushd(dir);
    await shell.run('''
    
  pub get
  dart tool/travis.dart
  
''');
    shell = shell.popd();
  }

  if ((await which('flutter')) != null) {
    for (var dir in [
      'firebase_flutter',
    ]) {
      shell = shell.pushd(dir);
      await shell.run('''
    
  pub get
  dart tool/travis.dart
  
''');
      shell = shell.popd();
    }
  }
}
