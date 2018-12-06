import 'dart:async';

import 'package:tekartik_build_utils/webdev/webdev.dart';

Future main() async {
  print('Serving `example` on http://localhost:8001/example_ui.html');
  print('Serving `example` on http://localhost:8001/example_auth.html');
  await serve(['example:8001', "--live-reload", "--hostname", "0.0.0.0"]);
}
