import 'package:tekartik_app_dev_menu/dev_menu.dart';
import 'package:tekartik_firebase/firebase.dart';

export 'package:tekartik_app_dev_menu/dev_menu.dart';

/// Top doc context
class FirebaseMainMenuContext {
  final FirebaseAppOptions? options;
  final Firebase firebase;
  FirebaseMainMenuContext({required this.firebase, this.options});
}

void firebaseMainMenu({required FirebaseMainMenuContext context}) {
  FirebaseApp? app;
  var firebase = context.firebase;
  menu('app', () {
    item('initializeAppAsync', () async {
      app = await firebase.initializeAppAsync(
        name: 'async',
        options: context.options,
      );
    });
    item('initializeApp', () async {
      app = firebase.initializeApp(options: context.options);
    });
    item('delete', () async {
      await app?.delete();
    });
    item('properties', () async {
      write(app?.options.toString());
      write('isLocal: ${app?.isLocal}');
      write('name: ${app?.name}');
    });
  });
}
