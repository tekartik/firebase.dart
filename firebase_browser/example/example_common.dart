// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/out_buffer.dart';
import 'package:web/web.dart' as web;

OutBuffer _outBuffer = OutBuffer(100);
web.Element? _output = web.document.getElementById('output');

void write([Object? message]) {
  print(message);
  _output?.textContent = (_outBuffer..add('$message')).toString();
}
