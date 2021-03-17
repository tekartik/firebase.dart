import 'package:tekartik_app_http/app_http.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';

/// Create new firestore client without auth
App noAuthAppRest({required String? projectId}) {
  var firebase = firebaseRest;
  var app = firebase.initializeApp(
      options: AppOptionsRest(client: httpClientFactory.newClient())
        ..projectId = projectId);
  return app;
}
