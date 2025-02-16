@JS()
@Deprecated('Do not use')
library;

import 'dart:js' as js;

import 'package:js/js.dart';

bool get hasRequire => js.context['require'] != null;

@JS('require')
external dynamic requireJs(String id);
