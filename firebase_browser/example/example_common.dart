import 'dart:html';

import 'package:tekartik_common_utils/out_buffer.dart';

OutBuffer _outBuffer = OutBuffer(100);
Element _output = document.getElementById("output");

write([Object message]) {
  print(message);
  _output.text = (_outBuffer..add("$message")).toString();
}
