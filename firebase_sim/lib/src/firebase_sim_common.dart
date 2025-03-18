import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:tekartik_firebase_sim/rpc_message.dart';

void log(String tag, Object? message) {
  // ignore: avoid_print
  print('/$tag $message');
}

Map<String, dynamic>? requestParams(Request request) =>
    request.params as Map<String, dynamic>?;

Map<String, dynamic>? notificationParams(Notification notification) =>
    notification.params as Map<String, dynamic>?;

Map<String, dynamic> resultAsMap(dynamic result) {
  return (result as Map).cast<String, dynamic>();
}

Map<String, dynamic>? rpcParams(Parameters parameters) {
  return (parameters.value as Map?)?.cast<String, dynamic>();
}
