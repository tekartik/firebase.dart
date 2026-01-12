import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:tekartik_common_utils/map_utils.dart';

/// Log message.
void log(String tag, Object? message) {
  // ignore: avoid_print
  print('/$tag $message');
}

/// Result as map.
Map<String, Object?> resultAsMap(Object? result) =>
    anyAsMap<String, Object?>(result!);

/// RPC parameters.
Map<String, dynamic>? rpcParams(Parameters parameters) {
  return (parameters.value as Map?)?.cast<String, dynamic>();
}
