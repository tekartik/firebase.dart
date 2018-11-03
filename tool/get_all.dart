//import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:tekartik_build_utils/common_import.dart';

Future getAll(List<String> packages) async {
  var futures = <Future>[];
  for (var package in packages) {
    futures.add(runCmd(PubCmd(pubGetArgs())..workingDirectory = package));
  }
  await Future.wait(futures);
}

Future flutterGetAll(List<String> packages) async {
  if (isFlutterSupported) {
    var futures = <Future>[];
    for (var package in packages) {
      await runCmd(FlutterCmd(['packages', 'get'])..workingDirectory = package);
    }
    await Future.wait(futures);
  }
}

var packages = [
  'firebase',
  'firebase_browser',
  'firebase_sembast',
  'firebase_sim',
  'firebase_test',
  'firebase_sim_io',
  'firebase_sim_browser'
];

var flutterPackages = ['firebase_flutter'];

Future main() async {
  await Future.wait([getAll(packages), flutterGetAll(flutterPackages)]);
}
