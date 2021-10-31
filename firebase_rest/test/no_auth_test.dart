@TestOn('vm')
library no_auth_test;

import 'package:process_run/shell.dart';
import 'package:test/test.dart';

void main() {
  var env = ShellEnvironment();
  var projectId = env['TEKARTIK_FIRESTORE_REST_NO_AUTH_PROJECT_ID'];
  var rootPath = env['TEKARTIK_FIRESTORE_REST_NO_AUTH_ROOT_PATH'];
  print('projectId: $projectId');
  print('rootPath: $rootPath');
  group('firestore', () {
    test('Basic', () async {
      /*
      var app = noAuthAppRest(projectId: projectId);
      expect((app.options as AppOptionsRest).client, isNotNull);

       */
    });
  }, skip: (projectId == null || rootPath == null));
}
