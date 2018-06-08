@TestOn("browser")
library tekartik_firebase_sim_browser.firebase_sim_browser_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim_client.dart';
import 'package:tekartik_web_socket_browser/web_socket_browser.dart';
import 'package:test/test.dart';

//import 'package:tekartik_serial_wss_client/channel/channel.dart';

main() {
  test('admin', () async {
    Firebase admin = new FirebaseSim(
        clientFactory: webSocketClientChannelFactoryBrowser, url: "ws://dummy");

    var app = admin.initializeApp();

    try {
      var snapshot = await app.firestore().doc("test").get();
      print(snapshot?.exists);
    } catch (e) {}
  });
}
