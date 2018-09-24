//import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:tekartik_build_utils/common_import.dart';

Future testFirebase() async {
  var dir = 'firebase';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(pubCmd(pubRunTestArgs(platforms: ['vm', 'chrome']))
    ..workingDirectory = dir);
}

Future testFirebaseSembast() async {
  var dir = 'firebase_sembast';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: ['vm']))..workingDirectory = dir);
}

Future testFirebaseSim() async {
  var dir = 'firebase_sim';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(pubCmd(pubRunTestArgs(platforms: ['vm', 'chrome']))
    ..workingDirectory = dir);
}

Future testFirebaseSimIo() async {
  var dir = 'firebase_sim_io';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: ['vm']))..workingDirectory = dir);
}

Future testFirebaseSimBrowser() async {
  var dir = 'firebase_sim_browser';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  /*
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: ['chrome']))..workingDirectory = dir);
      */
}

Future testFirebaseNode() async {
  var dir = 'firebase_node';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(
      pubCmd(pubRunTestArgs(platforms: ['node']))..workingDirectory = dir);
}

Future testFirebaseFlutter() async {
  var dir = 'firebase_flutter';
  await runCmd(flutterCmd(['packages', 'get'])..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib'])..workingDirectory = dir);
}

Future testFirebaseTest() async {
  var dir = 'firebase_test';
  await runCmd(pubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(dartanalyzerCmd(['lib'])..workingDirectory = dir);
}

Future main() async {
  await testFirebase();
  await testFirebaseSembast();
  await testFirebaseSim();
  await testFirebaseSimBrowser();
  await testFirebaseSimIo();
  await testFirebaseNode();
  await testFirebaseFlutter();
  await testFirebaseTest();
}
