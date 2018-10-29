//import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:tekartik_build_utils/common_import.dart';

Future testFirebase() async {
  var dir = 'firebase';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(PubCmd(pubRunTestArgs(platforms: ['vm', 'chrome']))
    ..workingDirectory = dir);
}

Future testFirebaseSembast() async {
  var dir = 'firebase_sembast';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['vm']))..workingDirectory = dir);
}

Future testFirebaseSim() async {
  var dir = 'firebase_sim';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(PubCmd(pubRunTestArgs(platforms: ['vm', 'chrome']))
    ..workingDirectory = dir);
}

Future testFirebaseSimIo() async {
  var dir = 'firebase_sim_io';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['vm']))..workingDirectory = dir);
}

Future testFirebaseBrowser() async {
  var dir = 'firebase_browser';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  /*
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['chrome']))..workingDirectory = dir);
      */
}

Future testFirebaseSimBrowser() async {
  var dir = 'firebase_sim_browser';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  /*
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['chrome']))..workingDirectory = dir);
      */
}

Future testFirebaseNode() async {
  var dir = 'firebase_node';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib', 'test'])..workingDirectory = dir);
  await runCmd(
      PubCmd(pubRunTestArgs(platforms: ['node']))..workingDirectory = dir);
}

Future testFirebaseFlutter() async {
  var dir = 'firebase_flutter';
  await runCmd(FlutterCmd(['packages', 'get'])..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib'])..workingDirectory = dir);
}

Future testFirebaseTest() async {
  var dir = 'firebase_test';
  await runCmd(PubCmd(pubGetArgs())..workingDirectory = dir);
  await runCmd(DartAnalyzerCmd(['lib'])..workingDirectory = dir);
}

Future main() async {
  await testFirebase();
  await testFirebaseBrowser();
  await testFirebaseSembast();
  await testFirebaseSim();
  await testFirebaseSimBrowser();
  await testFirebaseSimIo();
  await testFirebaseNode();
  await testFirebaseFlutter();
  await testFirebaseTest();
}
