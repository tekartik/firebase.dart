import 'dart:async';
import 'package:process_run/shell.dart';

Future main() async {
  print('Serving `example` on http://localhost:8001/example_ui.html');
  print('Serving `example` on http://localhost:8001/example_firebase.html');
  await Shell().run(
    'webdev serve example:8001 --auto=refresh --hostname 0.0.0.0',
  );
}
