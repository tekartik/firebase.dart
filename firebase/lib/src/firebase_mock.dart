import 'package:tekartik_firebase/firebase_admin.dart';
import 'package:tekartik_firebase/firebase_mixin.dart';

String get _defaultAppName => firebaseAppNameDefault;
String get _defaultProjectId => 'mock';

/// Firebase mock implementation.
class FirebaseMock with FirebaseWithAppsMixin, FirebaseMixin {
  @override
  FirebaseApp initializeApp({FirebaseAppOptions? options, String? name}) {
    name ??= _defaultAppName;
    checkAppNameUninitialized(name);
    var app = FirebaseAppMock(firebaseMock: this, options: options, name: name);
    return addApp(app);
  }
}

/// Firebase admin mock implementation.
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
    return addApp(app);
  }
}

/// Firebase app mock implementation.
class FirebaseAppMock with FirebaseAppMixin {
  /// The parent firebase mock instance.
  final FirebaseMock firebaseMock;

  /// Constructor.
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
  FirebaseMock get firebase => firebaseMock;

  @override
  Future<void> delete() async {
    await closeServices();
    firebaseMock.uninitializeApp(this);
  }

  @override
  late final String name;

  @override
  late final AppOptions options;
}

/// Firebase admin app mock implementation.
class FirebaseAdminAppMock extends FirebaseAppMock {
  /// Constructor.
  FirebaseAdminAppMock({
    required super.firebaseMock,
    super.options,
    super.name,
  });

  @override
  bool get hasAdminCredentials => true;
}

/// Mock app options.
// ignore: unreachable_from_main
class FirebaseAppOptionsMock with FirebaseAppOptionsMixin {}

/// Test base definition for mock products.
abstract class FirebaseAppProductMockBase
    implements FirebaseAppProduct<FirebaseAppProductMockBase> {}

/// Mock product implementation.
class FirebaseAppProductMock
    with FirebaseAppProductMixin<FirebaseAppProductMockBase>
    implements FirebaseAppProductMockBase {
  @override
  final FirebaseApp app;

  /// Constructor.
  FirebaseAppProductMock(this.app);
}

/// Mock product service implementation.
class FirebaseProductServiceMock
    with FirebaseProductServiceMixin<FirebaseAppProductMockBase> {
  /// Count of initializations.
  int initCount = 0;

  /// Get or create the product for the app.
  FirebaseAppProductMock product(App app) =>
      getInstance<FirebaseAppProductMock>(
        app,
        () => FirebaseAppProductMock(app),
      );

  @override
  Future<void> close(App app) async {
    initCount--;
    await super.close(app);
  }

  @override
  Future<void> init(App app) async {
    initCount++;
    await super.init(app);
  }
}
