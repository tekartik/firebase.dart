import 'package:tekartik_app_dev_menu/dev_menu.dart';
import 'package:tekartik_firebase/firebase.dart';

export 'package:tekartik_app_dev_menu/dev_menu.dart';

/// Top doc context
class FirebaseMainMenuContext {
  final Firebase firebase;
  FirebaseMainMenuContext({required this.firebase});
}

void firebaseMainMenu({required FirebaseMainMenuContext context}) {
  FirebaseApp? app;
  var firebase = context.firebase;
  menu('app', () {
    item('initializeAppAsync', () async {
      app = await firebase.initializeAppAsync();
    });
    item('initializeApp', () async {
      app = firebase.initializeApp();
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
