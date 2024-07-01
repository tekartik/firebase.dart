import 'package:dev_build/package.dart';
import 'package:path/path.dart';

var topDir = '..';

Future<void> main() async {
  for (var dir in [
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
