@JS()
library tekartik_firebase_browser_interop;

import 'dart:js' as js;

import 'package:js/js.dart';

bool get hasRequire => js.context['require'] != null;

@JS('require')
external dynamic requireWithCallback(List<String> id, Function callback);

@JS('require')
external dynamic requireJs(String id);
