import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/src/firebase_mixin.dart'; // ignore: implementation_imports
import 'package:meta/meta.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';

String get _defaultAppName => firebaseAppNameDefault;

/// The app options to use for REST app initialization.
abstract class AppOptionsRest extends AppOptions {
  /// Create a new options object.
  factory AppOptionsRest({@required AuthClient authClient}) =>
      AppOptionsRestImpl(authClient: authClient);
}

Firebase firebaseRest = FirebaseRestImpl();

// const String googleApisAuthDatastoreScope =
//    'https://www.googleapis.com/auth/datastore';
const String googleApisAuthCloudPlatformScope =
    'https://www.googleapis.com/auth/cloud-platform';

class AppOptionsRestImpl extends AppOptions implements AppOptionsRest {
  final AuthClient authClient;

  AppOptionsRestImpl({@required this.authClient});
}

class FirebaseRestImpl with FirebaseMixin implements FirebaseRest {
  @override
  App initializeApp({AppOptions options, String name}) {
    name ??= _defaultAppName;
    var impl = AppRestImpl(
      name: name,
      firebaseRest: this,
      options: options,
    );
    _apps[impl.name] = impl;
    return impl;
  }

  final _apps = <String, AppRestImpl>{};

  @override
  App app({String name}) {
    name ??= _defaultAppName;
    return _apps[name];
  }
}

FirebaseRestImpl _impl;
FirebaseRestImpl get impl => _impl ??= FirebaseRestImpl();

class AppRestImpl with FirebaseAppMixin implements AppRest {
  final FirebaseRestImpl firebaseRest;

  @override
  final AppOptions options;

  bool deleted = false;
  @override
  String name;

  AppRestImpl(
      {@required this.firebaseRest, @required this.options, this.name}) {
    name ??= _defaultAppName;
  }

  @override
  Future<void> delete() async {
    deleted = true;
    await closeServices();
  }

  @override
  AuthClient get authClient => (options as AppOptionsRestImpl)?.authClient;
}
