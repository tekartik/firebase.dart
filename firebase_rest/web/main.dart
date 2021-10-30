import 'dart:convert';
import 'dart:html';

import 'package:tekartik_firebase_rest/firebase_rest.dart';

Element get _output => querySelector('#output') as Element;
void write(String message) {
  var lines = LineSplitter.split(_output.text ?? '').toList();
  if (lines.length > 100) {
    lines = lines.sublist(10);
  }
  lines.add(message);
  _output.text = lines.join('\n');
}

void main() {
  write('Your Dart app is running. $firebaseRest');
}
