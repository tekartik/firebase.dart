import 'dart:async';
import 'package:http/browser_client.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_browser/firebase_browser.dart';
import 'package:yaml/yaml.dart';

Future<AppOptions> setup() async {
  // Load javascript
  await loadFirebaseJs();
  var client = BrowserClient();

  // Load client info
  try {
    var sample = await client.read('sample.local.config.yaml');

    try {
      var local = await client.read('local.config.yaml');
      var map = (loadYaml(local) as Map).cast<String, dynamic>();
      var options = AppOptions.fromMap(map);
      if (options.projectId == null) {
        print('Missing "projectId" in local.config.yaml');
        return null;
      }
      return options;
    } catch (e) {
      print(e);
      print('Cannot find local.config.yaml');
      print(
          'Create it from the sample.local.config.yaml file with your firebase information');
      print(sample);
    }
  } catch (e) {
    print(e);
    print('Cannot find sample.local.config.yaml');
    print('Make sure to run the test using something like: ');
    print('  pub run build_runner test --fail-on-severe -- -p chrome');
  }
  return null;
}
