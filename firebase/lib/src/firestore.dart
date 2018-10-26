import 'package:tekartik_firebase/firestore.dart';

DateTime toLocaleTime(DateTime value) {
  if (value == null || !value.isUtc) {
    return value;
  }
  return value.toLocal();
}

DateTime parseDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  } else if (value is String) {
    String text = value;
    try {
      return DateTime.parse(text);
    } catch (e) {
      //print(text);
      //print(text.substring(18));
      if (text.length > 23 &&
          text.substring(text.length - 1, text.length) == 'Z') {
        text = value.substring(0, 23) + 'Z';
        //print(text);
        return DateTime.parse(text);
      }
    }
  }
  return null;
}

dynamic valueToDocumentValue(dynamic value) {
  if (value == null ||
      value is num ||
      value is bool ||
      value is String ||
      value is DateTime ||
      value is FieldValue) {
    return value;
  } else if (value is Iterable) {
    return value.map((item) => valueToDocumentValue(value)).toList();
  } else if (value is Map) {
    return value
        .map((key, value) => MapEntry(key, valueToDocumentValue(value)))
        .cast<String, dynamic>();
  } else {
    throw ArgumentError.value(value, "${value.runtimeType}",
        "Unsupported value for fieldValueFromJsonValue");
  }
}

class DocumentDataMap implements DocumentData {
  Map<String, dynamic> get map => _map;
  Map<String, dynamic> _map;

  // use the given map as the data holder (so will be modified)
  DocumentDataMap({Map<String, dynamic> map}) {
    _map = map ?? {};
  }

  @override
  // Regular map
  Map<String, dynamic> asMap() => map;

  @override
  String getString(String key) => getValue(key) as String;

  @override
  setNull(String key) => setValue(key, null);

  void setValue(String key, dynamic value) => map[key] = value;

  dynamic valueAtFieldPath(String fieldPath) {
    List<String> parts = fieldPath.split("\.");
    Map parent = map;
    var value;
    for (int i = 0; i < parts.length; i++) {
      var part = parts[i];
      value = parent[part];
      if (value is Map) {
        parent = value;
      } else if (i < parts.length - 1) {
        // end not reached, abort
        return null;
      }
    }
    return value;
  }

  dynamic getValue(String key) => map[key];

  @override
  setString(String key, String value) => setValue(key, value);

  @override
  bool containsKey(String key) => _map.containsKey(key);

  @override
  setFieldValue(String key, FieldValue value) => setValue(key, value);

  @override
  void setInt(String key, int value) => setValue(key, value);

  @override
  int getInt(String key) => getValue(key) as int;

  @override
  bool getBool(String key) => getValue(key) as bool;

  @override
  num getNum(String key) => getValue(key) as num;

  @override
  void setBool(String key, bool value) => setValue(key, value);

  @override
  void setNum(String key, num value) => setValue(key, value);

  @override
  DateTime getDateTime(String key) =>
      toLocaleTime(parseDateTime(getValue(key)));

  @override
  void setDateTime(String key, DateTime value) => setValue(key, value);

  @override
  DocumentData getData(String key) {
    var value = getValue(key);
    if (value is Map) {
      return DocumentDataMap()..map.addAll(value.cast<String, dynamic>());
    }
    return null;
  }

  @override
  void setData(
    String key,
    DocumentData value,
  ) =>
      setValue(key, (value as DocumentDataMap).map);

  @override
  getProperty(String key) => getValue(key);

  @override
  bool has(String key) => containsKey(key);

  @override
  Iterable<String> get keys => map.keys;

  @override
  void setProperty(String key, value) {
    setValue(key, valueToDocumentValue(value));
  }

  @override
  List<T> getList<T>(String key) => (getValue(key) as List)?.cast<T>();

  @override
  void setList<T>(String key, List<T> list) => setValue(key, list);

  @override
  DocumentReference getDocumentReference(String key) =>
      getValue(key) as DocumentReference;

  @override
  void setDocumentReference(String key, DocumentReference doc) =>
      setValue(key, doc);

  @override
  Blob getBlob(String key) => getValue(key) as Blob;

  @override
  void setBlob(String key, Blob blob) {
    setValue(key, blob);
  }

  @override
  GeoPoint getGeoPoint(String key) => getValue(key) as GeoPoint;

  @override
  void setGeoPoint(String key, GeoPoint geoPoint) {
    setValue(key, geoPoint);
  }
}

enum FieldValueMapValue {
  delete,
  serverTimestamp,
}

/// Represents Firestore timestamp object.
class Timestamp implements Comparable<Timestamp> {
  final int seconds;
  final int nanoseconds;
  Timestamp(this.seconds, this.nanoseconds);

  static int tryParseNanoseconds(String text) {
    var len = text.length;
    var end = len - 1;
    if (text[end] == 'Z') {
      end--;
    }

    return null;
  }

  static Timestamp tryParseAny(Object object) {
    if (object is Timestamp) {
      return object;
    } else if (object is String) {
      return tryParse(object);
    } else if (object is DateTime) {
      return Timestamp.fromDateTime(object);
    }
    return null;
  }

  static Timestamp tryParse(String text) {
    if (text != null) {
      // 2018-10-20T05:13:45.985343Z
      var dateTime = DateTime.tryParse(text);
      var len = text.length;
      var end = len;
      if (text[end - 1] == 'Z') {
        end--;
      }
      int seconds;
      int nanos = 0;
      if (end > 3 && text[end - 4] == '.') {
        // Ok nothing to parse more
        if (dateTime != null) {
          nanos = (dateTime.millisecondsSinceEpoch % 1000) * 1000000;
        }
      } else if (end > 6 && text[end - 7] == '.') {
        int micros = int.tryParse(text.substring(end - 6, end));
        if (micros != null) {
          nanos = micros * 1000;
        }
      } else if (end > 9 && text[end - 10] == '.') {
        // remove nanos
        dateTime ??= DateTime.tryParse(
            '${text.substring(0, end - 3)}${text.substring(end)}');

        nanos = int.tryParse(text.substring(end - 9, end));
      }
      if (dateTime != null && nanos != null) {
        seconds ??= (dateTime.millisecondsSinceEpoch / 1000).floor();
        return Timestamp(seconds, nanos);
      }
    }
    return null;
  }

  factory Timestamp.fromDateTime(DateTime dateTime) {
    final int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    final int nanoseconds = (dateTime.microsecondsSinceEpoch % 1000000) * 1000;
    return Timestamp(seconds, nanoseconds);
  }

  factory Timestamp.now() => Timestamp.fromDateTime(DateTime.now());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Timestamp) {
      Timestamp typedOther = other;
      return seconds == typedOther.seconds &&
          nanoseconds == typedOther.nanoseconds;
    }
    return false;
  }

  @override
  int get hashCode => (seconds ?? 0) + (nanoseconds ?? 0);

  int get millisecondsSinceEpoch {
    return (seconds * 1000 + nanoseconds / 10000000).floor();
  }

  int get microsecondsSinceEpoch {
    return (seconds * 1000000 + nanoseconds / 1000).floor();
  }

  DateTime toDateTime({bool isUtc}) {
    return DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch,
        isUtc: isUtc == true);
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "${n}";
    if (n >= 10) return "0${n}";
    return "00${n}";
  }

  String toIso8601String() {
    var text = toDateTime(isUtc: true).toIso8601String();
    // handle micros for node and browser
    int microsOnly = nanoseconds % 1000000;
    if (microsOnly != 0) {
      int micros = (microsOnly / 1000).floor();
      var len = text.length;
      // Append micros if needed
      if ((text[len - 1] == 'Z') && (text[len - 5] == '.')) {
        return '${text.substring(0, len - 1)}${_threeDigits(micros)}Z';
      }
    }
    return text;
  }

  @override
  String toString() => toIso8601String();

  @override
  int compareTo(Timestamp other) {
    if (seconds != other.seconds) {
      return seconds - other.seconds;
    }
    return nanoseconds - other.nanoseconds;
  }
}
