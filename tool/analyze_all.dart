//import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:tekartik_build_utils/common_import.dart';

import 'get_all.dart';

Future analyzeAll(List<String> packages) async {
  var futures = <Future>[];
  for (var package in packages) {
    var dirs = (await Directory(package).list().toList())
        .where((fse) => FileSystemEntity.isDirectorySync(fse.path))
        .map((fse) => basename(fse.path))
        .toList()
          ..remove('.dart_tool');
    futures.add(runCmd(DartAnalyzerCmd(['--fatal-warnings']..addAll(dirs))..workingDirectory = package));
  }
  await Future.wait(futures);
}

Future flutterAnalyzeAll(List<String> packages) async {
  if (isFlutterSupported) {
    var futures = <Future>[];
    for (var package in packages) {
      await runCmd(FlutterCmd(['analyze'])..workingDirectory = package);
    }
    await Future.wait(futures);
  }
}

Future main() async {
  await Future.wait([analyzeAll(packages), flutterAnalyzeAll(flutterPackages)]);
}
