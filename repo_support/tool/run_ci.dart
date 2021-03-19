import 'package:dev_test/package.dart';
import 'package:path/path.dart';

var topDir = '..';

Future<void> main() async {
  for (var dir in [
    'firebase_rest',
    'firebase',
    'firebase_browser',
    'firebase_local',
    // 'firebase_node',
    'firebase_sim',
    'firebase_sim_browser',
    'firebase_sim_io',
    'firebase_test',
  ]) {
    await packageRunCi(join(topDir, dir));
  }
}
