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
