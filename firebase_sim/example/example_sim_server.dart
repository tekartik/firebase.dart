// ignore_for_file: avoid_print

import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';

import 'vars_menu.dart';

Future<void> main(List<String> args) async {
  var firebaseSimServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelServerFactoryIo,
    port: simPortKvValue,
  );
  print('url ${firebaseSimServer.url}');
}
