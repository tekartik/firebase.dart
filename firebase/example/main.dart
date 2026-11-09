// ignore_for_file: avoid_print

/// tekartik_firebase alone, without a backend package: a minimal backend and
/// a product built on the mixins, the way the real backends
/// (tekartik_firebase_local, _rest, _flutter, _node) and products (auth,
/// firestore, storage) are written.
///
/// An app uses a backend getter instead (`firebaseFlutter`, `firebaseRest`,
/// `newFirebaseMemory()`...), see the README.
library;

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';

/// A backend: one per platform, created once.
class FirebaseFake with FirebaseWithAppsMixin, FirebaseMixin {
  @override
  bool get isLocal => true;

  @override
  FirebaseApp initializeApp({FirebaseAppOptions? options, String? name}) {
    name ??= firebaseAppNameDefault;
    checkAppNameUninitialized(name);
    return addApp(FirebaseAppFake(this, options ?? FirebaseAppOptions(), name));
  }
}

/// An app of the fake backend.
class FirebaseAppFake with FirebaseAppMixin {
  @override
  final FirebaseFake firebase;
  @override
  final FirebaseAppOptions options;
  @override
  final String name;

  FirebaseAppFake(this.firebase, this.options, this.name);
}

/// A product interface (like `Firestore`), one instance per app.
abstract class Counter implements FirebaseAppProduct<Counter> {
  int next();
}

class _CounterImpl with FirebaseAppProductMixin<Counter> implements Counter {
  @override
  final FirebaseApp app;
  var _value = 0;

  _CounterImpl(this.app);

  @override
  int next() => ++_value;
}

/// The product service (like `firestoreService`), a global.
class CounterService with FirebaseProductServiceMixin<Counter> {
  /// The counter of [app], created on first access.
  Counter counter(FirebaseApp app) =>
      getInstance<_CounterImpl>(app, () => _CounterImpl(app));
}

final counterService = CounterService();

Future<void> main() async {
  var firebase = FirebaseFake();
  var app = firebase.initializeApp(
    options: FirebaseAppOptions(projectId: 'my-project'),
  );
  print('app ${app.name} project ${app.projectId}'); // [DEFAULT] my-project

  var counter = counterService.counter(app);
  print(counter.next()); // 1
  // Same instance for the same app, also reachable from the app.
  print(identical(counterService.counter(app), counter)); // true
  print(identical(app.getProduct<Counter>(), counter)); // true

  // Closes the services and disposes the products.
  await app.delete();
  print((counter as _CounterImpl).disposed); // true
  print(Firebase.apps.contains(app)); // false
}
