library tekartik_firebase.firebase_test;

import 'package:tekartik_firebase/firebase.dart';
import 'package:test/test.dart';

void main() {
  group('firebase', () {
    test('api', () {
      // ignore: unnecessary_statements
      Firebase;
      // ignore: unnecessary_statements
      FirebaseAppService;
      // ignore: unnecessary_statements
      App;
      // ignore: unnecessary_statements
      FirebaseApp;
      // ignore: unnecessary_statements
      AppOptions;
      // ignore: unnecessary_statements
      FirebaseAsync;
    });
    test('options', () {
      var options = AppOptions.fromMap({
        'apiKey': '1',
        'authDomain': '2',
        'databaseURL': '3',
        'projectId': '4',
        'storageBucket': '5',
        'messagingSenderId': '6'
      });
      expect(options.apiKey, '1');
      expect(options.authDomain, '2');
      expect(options.databaseURL, '3');
      expect(options.projectId, '4');
      expect(options.storageBucket, '5');
      expect(options.messagingSenderId, '6');
    });
  });
}
