import 'package:tekartik_common_utils/string_utils.dart';

void log(String tag, Object? message) {
  // ignore: avoid_print
  print('/$tag ${message?.toString().truncate(1000)}');
}
