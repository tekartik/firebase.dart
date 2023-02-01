@JS()
library tekartik_firebase_client_browser.src.bindings;

import 'package:js/js.dart';

/// Returns a list of keys in a JavaScript [object].
///
/// This function binds to JavaScript `Object.keys()`.
@JS('Object.keys')
external List<String> objectKeys(Object? object);
