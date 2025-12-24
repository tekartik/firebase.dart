import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';
import 'package:tekartik_firebase_test/firebase_test.dart';

String get _defaultAppName => firebaseAppNameDefault;
String get _defaultProjectId => 'mock';

class FirebaseMock with FirebaseMixin {
  final _apps = <String, App?>{};
  @override
  App initializeApp({AppOptions? options, String? name}) {
    name ??= _defaultAppName;
    var app = FirebaseAppMock(firebaseMock: this, options: options, name: name);
    _apps[name] = FirebaseMixin.latestFirebaseInstanceOrNull = app;
    return app;
  }

  @override
  App app({String? name}) {
    return _apps[name ?? _defaultAppName]!;
  }
}

class FirebaseAdminMock extends FirebaseMock
    with FirebaseAdminMixin
    implements FirebaseAdmin {
  @override
  App initializeApp({AppOptions? options, String? name}) {
    name ??= _defaultAppName;
    var app = FirebaseAdminAppMock(
      firebaseMock: this,
      options: options,
      name: name,
    );
    _apps[name] = FirebaseMixin.latestFirebaseInstanceOrNull = app;
    return app;
  }
}

class FirebaseAppMock with FirebaseAppMixin {
  final FirebaseMock firebaseMock;
  FirebaseAppMock({
    required this.firebaseMock,
    String? name,
    AppOptions? options,
  }) {
    this.options = options ?? AppOptions()
      ..projectId = _defaultProjectId;
    this.name = name ?? _defaultAppName;
  }

  @override
  Firebase get firebase => firebaseMock;
  @override
  Future<void> delete() async {
    await closeServices();
  }

  @override
  late final String name;

  @override
  late final AppOptions options;
}

class FirebaseAdminAppMock extends FirebaseAppMock {
  FirebaseAdminAppMock({
    required super.firebaseMock,
    super.options,
    super.name,
  });

  @override
  bool get hasAdminCredentials => true;
}

// ignore: unreachable_from_main
class FirebaseAppOptionsMock with FirebaseAppOptionsMixin {}

void main() {
  runFirebaseTests(FirebaseMock());
  runFirebaseTests(FirebaseAdminMock());
}
