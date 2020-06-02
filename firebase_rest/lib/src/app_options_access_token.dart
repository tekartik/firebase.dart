// Token data
import 'package:googleapis_auth/auth.dart';
import 'package:http/http.dart';

import 'package:tekartik_firebase/firebase.dart';
import 'package:meta/meta.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';

AppOptions getAppOptionsFromAccessCredentials(
    Client client, AccessCredentials accessCredentials,
    {List<String> scopes, String projectId}) {
  var authClient = authenticatedClient(client, accessCredentials);
  var appOptions = AppOptionsRest(authClient: authClient)
    ..projectId = projectId;
  return appOptions;
}

AppOptions getAppOptionsFromAccessToken(Client client, String token,
    {@required String projectId, List<String> scopes}) {
  // expiry is ignored in request
  var accessToken = AccessToken('Bearer', token, DateTime.now().toUtc());
  var accessCredentials = AccessCredentials(accessToken, null, scopes);
  return getAppOptionsFromAccessCredentials(client, accessCredentials,
      projectId: projectId);
}
