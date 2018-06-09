import 'package:grinder/grinder.dart';
import 'package:tekartik_build_utils/bash/bash.dart';

main(List<String> args) => grind(args);

@Task()
test_firebase_browser() async {
  await bash('''
set -xe
pushd firebase_browser
pub run build_runner test --fail-on-severe -- -p chrome -r expanded
''', verbose: true);
}

@Task()
test_firebase_sembast() async {
  await bash('''
set -xe
pushd firebase_sembast
pub run test
''', verbose: true);
}

@DefaultTask()
test() async {
  await test_firebase_sembast();
  await test_firebase_browser();
}

@Task()
fmt() async {
  await bash('''
set -xe
dartfmt . -w
''', verbose: true);
}
