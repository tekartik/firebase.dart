import 'dart:async';

import 'package:process_run/shell_run.dart';

Future main() async {
  await run(
      'pub run build_runner test --fail-on-severe -- -p chrome -r expanded');
}
