// Token data
import 'package:googleapis_auth/auth.dart';
import 'package:http/http.dart';

import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase_rest/src/test/test_setup.dart';
import 'package:meta/meta.dart';

Future<AppOptions> getAppOptionsFromAccessToken(Client client, String token,
    {@required String projectId, List<String> scopes}) async {
  // expiry is ignored in request
  var accessToken = AccessToken('Bearer', token, DateTime.now().toUtc());
  var accessCredentials = AccessCredentials(accessToken, null, scopes);
  return getAppOptionsFromAccessCredentials(client, accessCredentials,
      projectId: projectId);
}
