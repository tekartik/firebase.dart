abstract class Message {
  Map<String, dynamic> toMap() {
    return {'jsonrpc': '2.0'};
  }

  // throw or return valid value
  static Message parseMap(Map<String, dynamic> map) {
    if (map['jsonrpc'] != '2.0') {
      throw FormatException("missing 'jsonrpc=2.0' in $map");
    }

    if (map.containsKey('id')) {
      var id = map['id'];
      if (map['method'] == null) {
        // response
        if (map.containsKey('result')) {
          return Response(id, map['result']);
        } else {
          final errorMap = map['error'] as Map;
          if (errorMap == null) {
            throw FormatException(
                "missing 'method', 'result' or 'error' in $map");
          }
          return ErrorResponse(
              id,
              Error(errorMap['code'] as int, errorMap['message'] as String,
                  errorMap['data']));
        }
      } else {
        return Request(id, map['method'] as String, map['params']);
      }
    } else {
      // notification
      if (map['method'] == null) {
        throw FormatException("missing 'method' or 'id' in $map");
      }
      return Notification(map['method'] as String, map['params']);
    }
  }

  @override
  String toString() => toMap().toString();
}

abstract class _MessageWithId extends Message {
  final dynamic /*String | int*/ id;

  _MessageWithId(this.id);

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['id'] = id;
    return map;
  }
}

class Notification extends Message with _RequestMixin {
  Notification(String method, [var params]) {
    _init(method, params);
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    _updateMap(map);
    return map;
  }
}

class _RequestMixin {
  dynamic _params;
  String _method;

  dynamic get params => _params;

  String get method => _method;

  void _init(String method, [dynamic params]) {
    _method = method;
    _params = params;
  }

  void _updateMap(Map map) {
    map['method'] = _method;
    if (_params != null) {
      map['params'] = _params;
    }
  }
}

class Request extends _MessageWithId with _RequestMixin {
  Request(dynamic /*String | int*/ id, String method, [var params])
      : super(id) {
    _init(method, params);
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    _updateMap(map);
    return map;
  }
}

class Response extends _MessageWithId {
  final dynamic result;

  Response(id, this.result) : super(id);

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['result'] = result;
    return map;
  }
}

class Error {
  final int code;
  final String message;
  final dynamic data;

  Error(this.code, this.message, [this.data]);

  Map<String, dynamic> toMap() {
    var map = {'code': code, 'message': message};
    if (data != null) {
      map['data'] = data;
    }
    return map;
  }

  @override
  String toString() {
    return '$code: $message${data != null ? ' $data' : ''}';
  }
}

class ErrorResponse extends _MessageWithId {
  final Error error;

  ErrorResponse(id, this.error) : super(id);

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['error'] = error.toMap();
    return map;
  }
}

const errorCodeMethodNotFound = 1;
const errorCodeSubscriptionNotFound = 2;
const errorCodeExceptionThrown = 3;
