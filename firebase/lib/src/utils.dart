import 'dart:math';

String? obfuscate(String? text) {
  if (text == null) {
    return null;
  }
  var keepCount = min(4, text.length ~/ 2);
  return '${List.generate(text.length - keepCount, (_) => '*').join()}${text.substring(text.length - keepCount)}';
}
