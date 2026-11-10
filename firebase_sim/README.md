# tekartik_firebase_sim

A Firebase simulator: a server process hosts a real `Firebase` (usually the
in memory `FirebaseLocal` of `tekartik_firebase_local`) and publishes it over
JSON-RPC on a web socket; clients (Dart VM, browser, Flutter) get a
`Firebase` whose apps and products forward every call to it. Handy to run a
web or Flutter app, or a `dart test -p chrome` suite, against local data
without cloud credentials.

This package is the bridge (apps, lifecycle, ping). The products come as
plugins: `tekartik_firebase_firestore_sim`, `tekartik_firebase_auth_sim`,
`tekartik_firebase_storage_sim`, `tekartik_firebase_functions_call_sim`.

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_firebase_sim:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_sim
  # The server side hosts a local firebase.
  tekartik_firebase_local:
    git:
      url: https://github.com/tekartik/firebase.dart
      path: firebase_local
```

Server and client in one program, over the in memory transport (no port):

```dart
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_web_socket/web_socket.dart';

Future<void> main() async {
  var simServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelFactoryMemory.server,
  );
  var firebase = getFirebaseSim(
    clientFactory: webSocketChannelFactoryMemory.client,
    uri: simServer.uri,
  );
  var app =
      await firebase.initializeAppAsync(
            options: FirebaseAppOptions(projectId: 'my-project'),
          )
          as FirebaseAppSim;
  await app.ping();
  print('server app: ${await app.getAppName()}');

  // Each app has its own connection, which delete() leaves open: close it.
  var simClient = await app.simClient;
  await app.delete();
  await simClient.close();
  await simServer.close();
}
```

In real use the server runs in a Dart VM process
(`webSocketChannelServerFactoryIo`, `port: firebaseSimDefaultPort`, 4996) and
the clients connect with `getFirebaseSim(uri: getFirebaseSimLocalhostUri())`.

## Platforms

| Side | Library | Runs on |
|---|---|---|
| client | `firebase_sim.dart` | Dart VM, web, Flutter |
| server | `firebase_sim_server.dart` | Dart VM only (`dart:io`) |
| plugin authors | `firebase_sim_mixin.dart`, `firebase_sim_server_mixin.dart` | as above |

## What to know

* The server must get the plugin of each product the clients use
  (`firebaseSimServe(..., plugins: [...])`), the clients the matching sim
  service; without plugin only the apps and `ping` work.
* `initializeApp` connects lazily; `await initializeAppAsync(...)` reports a
  server that cannot be reached right away.
* `app.delete()` releases the app on the server but leaves the connection of
  the app open (a client program would not exit): close
  `await app.simClient` after the delete, as above. `FirebaseSim.close()`
  does nothing.
* The server keeps the apps of a client that disconnects without
  `app.delete()`.
* Use `port: 0` (then `simServer.uri`) for tests run in parallel.
* `debugFirebaseSimClient` / `debugFirebaseSimServer` print every request and
  response.

The [tekartik-firebase-sim-setup skill](skills/tekartik-firebase-sim-setup/SKILL.md)
has more examples (io server, shared tests, writing a product plugin).
