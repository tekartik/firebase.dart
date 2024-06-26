// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/out_buffer.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:web/web.dart' as web;

OutBuffer _outBuffer = OutBuffer(100);
web.Element? _output = web.document.getElementById('output');

void write([Object? message]) {
  print(message);
  _output?.text = (_outBuffer..add('$message')).toString();
}

void main() {
  write('Your Dart app is running. $firebaseRest');
}
