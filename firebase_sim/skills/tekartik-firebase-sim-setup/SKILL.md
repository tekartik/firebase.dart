---
name: tekartik-firebase-sim-setup
description: >-
  Use when exposing a server-side Firebase instance (usually FirebaseLocal) over
  JSON-RPC/WebSocket with tekartik_firebase_sim so a client, a browser test or a
  Flutter app can drive it: firebaseSimServe, FirebaseSimServer, getFirebaseSim,
  getFirebaseSimIo, getFirebaseSimWeb, getFirebaseSimLocalhostUri,
  firebaseSimDefaultPort, FirebaseAppSim, debugFirebaseSimClient /
  debugFirebaseSimServer, the firebase_sim.dart / firebase_sim_server.dart /
  firebase_sim_mixin.dart / firebase_sim_server_mixin.dart imports, and when
  writing a product plugin (FirebaseSimPlugin, FirebaseSimServerServiceBase,
  onServiceCall / onAppCall) like the firestore, auth, storage sim packages.
---

# Firebase simulator client and server (tekartik_firebase_sim)

`tekartik_firebase_sim` is a JSON-RPC-over-WebSocket bridge, not a Firebase
backend. A server process hosts a real `Firebase` (in practice `FirebaseLocal`
from `tekartik_firebase_local`) and `firebaseSimServe` publishes it; clients get
a `Firebase` handle whose apps and products forward every call over the socket.
It lets a browser or Flutter app, or a `-p chrome` test, run against an
in-memory Firebase with no cloud credentials.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_firebase_sim:
      git:
        url: https://github.com/tekartik/firebase.dart
        path: firebase_sim
  ```
  The server side also needs a real backend to host, normally
  `tekartik_firebase_local` (same repo, `path: firebase_local`).
* Four public libraries, pick by role:
  * `package:tekartik_firebase_sim/firebase_sim.dart` — client;
  * `package:tekartik_firebase_sim/firebase_sim_server.dart` — server (VM
    only: it re-exports `package:tekartik_rpc/rpc_server.dart`, hence
    `webSocketChannelServerFactoryIo`, `RpcServer`, `RpcService`);
  * `firebase_sim_mixin.dart` — client-side plugin implementers
    (`FirebaseSimClient`, `FirebaseSimAppClient`, `ServerSubscriptionSim`,
    `resultAsMap`, `paramSubscriptionId`, `paramDone`);
  * `firebase_sim_server_mixin.dart` — server-side plugin implementers.
  `firebase_sim_message.dart` is empty (its exports are commented out): take
  `methodPing`, `methodAdminInitializeApp`, `BaseData` & co from
  `firebase_sim_server_mixin.dart`. Never import `src/...`.
* Client: `getFirebaseSim({clientFactory, uri, localPath})` returns a
  `FirebaseSim implements Firebase`. `clientFactory` defaults to the universal
  `webSocketChannelClientFactory` of `tekartik_app_web_socket`, so the same
  call works on the VM, the browser and Flutter; `getFirebaseSimIo(...)` and
  `getFirebaseSimWeb(...)` (also exported from `firebase_sim.dart`) only
  hardcode the io / browser factory and require `tekartik_web_socket_io` resp.
  `tekartik_web_socket_browser` as a direct dependency.
* `uri` defaults to `ws://localhost:$firebaseSimDefaultPort` (4996). Build it
  with `getFirebaseSimLocalhostUri(port: ...)` (or `getFirebaseSimPort(port)`);
  against a server started on port `0` use `Uri.parse(simServer.url)` or
  `simServer.uri`.
* Apps: `firebase.initializeApp(options:, name:)` returns a `FirebaseAppSim`
  synchronously but connects lazily; prefer
  `await firebase.initializeAppAsync(...)`, which awaits the RPC handshake, so
  a failure to reach the server surfaces immediately. Without `options` the
  project id is `firebaseSimDefaultProjectId` (`'sim'`). Apps of different
  project ids map to distinct server-side apps; the server-side app name is
  not the client one (`app.getAppName()` returns the real remote name,
  `app.getAppDelegateName()` the shared delegate). `await app.delete()` frees
  the server app; calls on a deleted app throw.
* `initializeApp` / `initializeAppAsync` are statically typed `FirebaseApp` on
  the `Firebase` interface: cast the result `as FirebaseAppSim` to reach the
  sim-specific members.
* `FirebaseAppSim` extras: `ping()` (round trip), `appServerId`, `simClient` /
  `simAppClient` (raw RPC senders used by product plugins), `options`, `name`.
  `FirebaseSim.close()` closes the client connection.
* Server: `await firebaseSimServe(firebase, {webSocketChannelServerFactory,
  plugins, port})` returns a `FirebaseSimServer` with `url`, `uri`, `close()`,
  `addPlugin()` and `initializeAppAsync(options:)` (pre-creates the server-side
  app for a project, e.g. so http functions start listening). Pass
  `webSocketChannelServerFactoryIo` for a real socket, `port: 0` for a free
  port, and read `simServer.url` afterwards. Always `await simServer.close()`
  in `tearDownAll`.
* Products (firestore, auth, storage, functions) are *not* in this package:
  the server must be started with their plugin and the client must use their
  sim service. `FirestoreSimPlugin` (`tekartik_firebase_firestore_sim`),
  `StorageSimPlugin` (`tekartik_firebase_storage_sim`), the auth sim plugin
  (`tekartik_firebase_auth_sim`) and `tekartik_firebase_functions_call_sim`
  all implement `FirebaseSimPlugin`. Without a plugin only app lifecycle and
  `ping` work.
* Tests without a socket: `webSocketChannelFactoryMemory` from
  `package:tekartik_web_socket/web_socket.dart` gives a matching
  `.server` / `.client` pair in the same isolate — the fastest way to run a
  client/server pair, same protocol. `webSocketChannelServerFactoryMemory` and
  `webSocketChannelClientFactoryMemory` are the same objects standalone.
* Debugging: set `debugFirebaseSimClient = true` (client) and
  `debugFirebaseSimServer = true` (server, logs every request/response and
  wraps services in a logger) before creating anything. Leave them `false` in
  committed code.
* Writing a plugin: implement `FirebaseSimPlugin` (mix in
  `FirebaseSimPluginDefaultMixin` unless you need `initForApp(app)`, called
  once per server-side app) and expose a `FirebaseSimServerService`, normally a
  `FirebaseSimServerServiceBase` subclass named after the product
  (`'firebase_firestore'`, `'firebase_core'`, ...). Its default `onCall` routes
  to `onAppCall(projectApp, channel, methodCall)` when the params map carries
  the app id (i.e. when the client sends through `FirebaseSimAppClient`), and
  to `onServiceCall(channel, methodCall)` otherwise; `projectApp.app` is the
  server-side `FirebaseApp`. Throw `RpcException` for unsupported methods, or
  call `super`. Stream subscriptions are shipped back with
  `ServerSubscriptionSim` plus `paramSubscriptionId` / `paramDone`.
* Shared suites: `runFirebaseTests(firebase)` from
  `package:tekartik_firebase_test/firebase_test.dart` runs the cross
  implementation app test suite against a sim client. Client-only tests can run
  in a browser (`dart test -p chrome`) as long as the server was started in a
  VM process first; the server library itself must never be imported by web
  code.

## Examples

### Server: publish a local Firebase on a real socket

```dart
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';

Future<void> main() async {
  var simServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelServerFactoryIo,
    port: firebaseSimDefaultPort,
  );
  print('serving ${simServer.url}');
}
```

### Client: connect, initialize an app, ping, delete

```dart
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';

Future<void> main() async {
  var firebase = getFirebaseSim(uri: getFirebaseSimLocalhostUri());
  var app =
      await firebase.initializeAppAsync(
            options: FirebaseAppOptions(projectId: 'my-project'),
            name: 'my_app',
          )
          as FirebaseAppSim;
  await app.ping();
  print('server app name: ${await app.getAppName()}');
  await app.delete();
  await firebase.close();
}
```

### Test: client and server in one isolate over the memory transport

```dart
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var simServer = await firebaseSimServe(
    FirebaseLocal(),
    webSocketChannelServerFactory: webSocketChannelFactoryMemory.server,
  );
  var firebase = getFirebaseSim(
    clientFactory: webSocketChannelFactoryMemory.client,
    uri: simServer.uri,
  );

  runFirebaseTests(firebase);

  test('app lifecycle', () async {
    var app =
        await firebase.initializeAppAsync(name: 'test_sim') as FirebaseAppSim;
    expect(app.options.projectId, firebaseSimDefaultProjectId);
    expect(await app.getAppName(), startsWith('test_sim'));
    await app.delete();
  });

  tearDownAll(() async {
    await simServer.close();
  });
}
```

### A product plugin: server service and its client call

```dart
import 'dart:async';

import 'package:tekartik_firebase_sim/firebase_sim.dart';
import 'package:tekartik_firebase_sim/firebase_sim_server_mixin.dart';

/// Server side: register with firebaseSimServe(..., plugins: [CounterSimPlugin()])
class CounterSimPlugin
    with FirebaseSimPluginDefaultMixin
    implements FirebaseSimPlugin {
  final counterSimServerService = CounterSimServerService();

  @override
  FirebaseSimServerService get simService => counterSimServerService;
}

class CounterSimServerService extends FirebaseSimServerServiceBase {
  static const serviceName = 'counter';
  static const methodIncrement = 'increment';

  final _counts = <String, int>{};

  CounterSimServerService() : super(serviceName);

  @override
  FutureOr<Object?> onAppCall(
    FirebaseSimServerProjectApp projectApp,
    RpcServerChannel channel,
    RpcMethodCall methodCall,
  ) async {
    if (methodCall.method == methodIncrement) {
      var key = projectApp.app!.name;
      return _counts[key] = (_counts[key] ?? 0) + 1;
    }
    return super.onAppCall(projectApp, channel, methodCall);
  }
}

/// Client side: goes through FirebaseSimAppClient so the app id is added
/// and the call is routed to onAppCall.
Future<int> increment(FirebaseAppSim app) async {
  var appClient = await app.simAppClient;
  return await appClient.sendRequest<int>(
    CounterSimServerService.serviceName,
    CounterSimServerService.methodIncrement,
    <String, Object?>{},
  );
}
```

## Common mistakes

* Importing `firebase_sim_server.dart` from web or Flutter code: it pulls
  `dart:io` through `tekartik_rpc`. Clients only import `firebase_sim.dart`.
* Expecting `firestore`/`auth`/`storage` to work without passing the matching
  `FirebaseSimPlugin` to `firebaseSimServe` on the server.
* Using `initializeApp` and assuming the connection is up: only
  `initializeAppAsync` (or the first `await`ed call) reports a dead server.
* Reusing `firebaseSimDefaultPort` for parallel test runs: use `port: 0` and
  `simServer.url`.
* Leaving `debugFirebaseSimServer`/`debugFirebaseSimClient` on, which prints
  every RPC payload (truncated at 1000 chars).
