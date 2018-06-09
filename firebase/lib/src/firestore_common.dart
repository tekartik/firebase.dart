import 'dart:convert';

import 'package:tekartik_common_utils/date_time_utils.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';

const String jsonTypeField = r"$t";
const String jsonValueField = r"$v";
const String typeDateTime = "DateTime";
const String typeFieldValue = "FieldValue";
const String typeDocumentReference = "DocumentReference";
const String typeGeoPoint = "GeoPoint";
const String typeBlob = "Blob";
const String valueFieldValueDelete = "~delete";
const String valueFieldValueServerTimestamp = "~serverTimestamp";

Map<String, dynamic> typeValueToJson(String type, dynamic value) {
  return <String, dynamic>{jsonTypeField: type, jsonValueField: value};
}

Map<String, dynamic> dateTimeToJsonValue(DateTime dateTime) =>
    typeValueToJson(typeDateTime, dateTimeToString(dateTime));

Map<String, dynamic> documentReferenceToJsonValue(
        DocumentReference documentReference) =>
    typeValueToJson(typeDocumentReference, documentReference?.path);

Map<String, dynamic> blobToJsonValue(Blob blob) => typeValueToJson(
    typeBlob, blob.data != null ? base64.encode(blob.data) : null);

Map<String, dynamic> fieldValueToJsonValue(FieldValue fieldValue) {
  if (fieldValue == FieldValue.delete) {
    return typeValueToJson(typeFieldValue, valueFieldValueDelete);
  } else if (fieldValue == FieldValue.serverTimestamp) {
    return typeValueToJson(typeFieldValue, valueFieldValueServerTimestamp);
  }
  throw new ArgumentError.value(fieldValue, "${fieldValue.runtimeType}",
      "Unsupported value for fieldValueToJsonValue");
}

FieldValue fieldValueFromJsonValue(dynamic value) {
  if (value == valueFieldValueDelete) {
    return FieldValue.delete;
  } else if (value == valueFieldValueServerTimestamp) {
    return FieldValue.serverTimestamp;
  }
  throw new ArgumentError.value(value, "${value.runtimeType}",
      "Unsupported value for fieldValueFromJsonValue");
}

DateTime jsonValueToDateTime(Map map) {
  if (map == null) {
    return null;
  }
  assert(map[jsonTypeField] == typeDateTime);
  return anyToDateTime(map[jsonValueField]);
}

DocumentReference jsonValueToDocumentReference(Firestore firestore, Map map) {
  if (map == null) {
    return null;
  }
  assert(map[jsonTypeField] == typeDocumentReference);
  return firestore.doc(map[jsonValueField] as String);
}

Blob jsonValueToBlob(Map map) {
  if (map == null) {
    return null;
  }
  assert(map[jsonTypeField] == typeBlob);
  var base64value = map[jsonValueField] as String;
  if (base64value == null) {
    return new Blob(null);
  } else {
    return new Blob(base64.decode(base64value));
  }
}

Map<String, dynamic> geoPointToJsonValue(GeoPoint geoPoint) {
  if (geoPoint == null) {
    return null;
  }
  return typeValueToJson(typeGeoPoint,
      {'latitude': geoPoint.latitude, 'longitude': geoPoint.longitude});
}

GeoPoint jsonValueToGeoPoint(Map map) {
  if (map == null) {
    return null;
  }
  assert(map[jsonTypeField] == typeGeoPoint);
  var valueMap = map[jsonValueField] as Map;
  return new GeoPoint(
      valueMap['latitude'] as num, valueMap['longitude'] as num);
}

// utilities

// common value in both format
bool _isCommonValue(dynamic value) {
  return (value == null) ||
      (value is String) ||
      (value is num) ||
      (value is bool);
}

dynamic documentDataValueToJson(dynamic value) {
  if (_isCommonValue(value)) {
    return value;
  } else if (value is List) {
    return value.map((value) => documentDataValueToJson(value)).toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) =>
        new MapEntry(key as String, documentDataValueToJson(value)));
  } else if (value is DocumentData) {
    // Handle this that could happen from a map
    return documentDataValueToJson((value as DocumentDataMap).map);
  } else if (value is DateTime) {
    return dateTimeToJsonValue(value);
  } else if (value is FieldValue) {
    return fieldValueToJsonValue(value);
  } else if (value is DocumentReference) {
    return documentReferenceToJsonValue(value);
  } else if (value is Blob) {
    return blobToJsonValue(value);
  } else if (value is GeoPoint) {
    return geoPointToJsonValue(value);
  } else {
    throw new ArgumentError.value(value, "${value.runtimeType}",
        "Unsupported value for documentDataValueToJson");
  }
}

dynamic jsonToDocumentDataValue(Firestore firestore, dynamic value) {
  if (_isCommonValue(value)) {
    return value;
  } else if (value is List) {
    return value
        .map((value) => jsonToDocumentDataValue(firestore, value))
        .toList();
  } else if (value is Map) {
    // Check encoded value
    var type = value[jsonTypeField] as String;
    if (type != null) {
      switch (type) {
        case typeDateTime:
          return anyToDateTime(value[jsonValueField])?.toLocal();
        case typeFieldValue:
          return fieldValueFromJsonValue(value[jsonValueField]);
        case typeDocumentReference:
          return jsonValueToDocumentReference(firestore, value);
        case typeBlob:
          return jsonValueToBlob(value);
        case typeGeoPoint:
          return jsonValueToGeoPoint(value);
        default:
          throw new UnsupportedError("value $value");
      }
    } else {
      return value.map<String, dynamic>((key, value) => new MapEntry(
          key as String, jsonToDocumentDataValue(firestore, value)));
    }
  } else {
    throw new ArgumentError.value(value, "${value.runtimeType}",
        "Unsupported value for jsonToDocumentDataValue");
  }
}

DocumentData documentDataFromJsonMap(
    Firestore firestore, Map<String, dynamic> map) {
  if (map == null) {
    return null;
  }
  return new DocumentDataMap(
      map: jsonToDocumentDataValue(firestore, map) as Map<String, dynamic>);
}

// will return null if map is null
DocumentData documentDataFromMap(Map<String, dynamic> map) {
  if (map != null) {
    return null;
  }
  return new DocumentData(map);
}

DocumentData documentDataFromSnapshot(DocumentSnapshot snapshot) =>
    snapshot?.exists == true ? new DocumentData(snapshot.data) : null;

Map<String, dynamic> documentDataToJsonMap(DocumentData documentData) {
  if (documentData == null) {
    return null;
  }
  return documentDataValueToJson((documentData as DocumentDataMap).map)
      as Map<String, dynamic>;
}

class OrderByInfo {
  String fieldPath;
  bool ascending;
}

class LimitInfo {
  String documentId;
  List values;
  bool inclusive; // true = At

  LimitInfo clone() {
    return new LimitInfo()
      ..documentId = documentId
      ..values = values
      ..inclusive = inclusive;
  }
}

class WhereInfo {
  String fieldPath;

  WhereInfo(
    this.fieldPath, {
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.isNull,
  });

  dynamic isEqualTo;
  dynamic isLessThan;
  dynamic isLessThanOrEqualTo;
  dynamic isGreaterThan;
  dynamic isGreaterThanOrEqualTo;
  bool isNull;
}

// Mutable, must be clone before
class QueryInfo {
  List<String> selectKeyPaths;
  List<OrderByInfo> orderBys = [];

  LimitInfo startLimit;
  LimitInfo endLimit;

  int limit;
  int offset;
  List<WhereInfo> wheres = [];

  QueryInfo clone() {
    return new QueryInfo()
      ..limit = limit
      ..offset = offset
      ..startLimit = startLimit?.clone()
      ..endLimit = endLimit?.clone()
      ..wheres = new List.from(wheres)
      ..selectKeyPaths = selectKeyPaths
      ..orderBys = new List.from(orderBys);
  }

  startAt({DocumentSnapshot snapshot, List values}) =>
      startLimit = (new LimitInfo()
        ..documentId = snapshot?.ref?.id
        ..values = values
        ..inclusive = true);

  startAfter({DocumentSnapshot snapshot, List values}) =>
      startLimit = (new LimitInfo()
        ..documentId = snapshot?.ref?.id
        ..values = values
        ..inclusive = false);

  endAt({DocumentSnapshot snapshot, List values}) => endLimit = (new LimitInfo()
    ..documentId = snapshot?.ref?.id
    ..values = values
    ..inclusive = true);

  endBefore({DocumentSnapshot snapshot, List values}) =>
      endLimit = (new LimitInfo()
        ..documentId = snapshot?.ref?.id
        ..values = values
        ..inclusive = false);

  addWhere(WhereInfo where) {
    wheres.add(where);
  }
}

WhereInfo whereInfoFromJsonMap(Firestore firestore, Map<String, dynamic> map) {
  bool isNull;
  var isEqualTo;
  var value = jsonToDocumentDataValue(firestore, map['value']);
  var operator = map['operator'];
  if (operator == operatorEqual) {
    if (value == null) {
      isNull = true;
    } else {
      isEqualTo = value;
    }
  } else if (operator == operatorLessThan) {}
  var whereInfo = new WhereInfo(map['fieldPath'] as String,
      isEqualTo: isEqualTo,
      isNull: isNull,
      isLessThan: (operator == operatorLessThan) ? value : null,
      isLessThanOrEqualTo: (operator == operatorLessThanOrEqual) ? value : null,
      isGreaterThan: (operator == operatorGreaterThan) ? value : null,
      isGreaterThanOrEqualTo:
          (operator == operatorGreaterThanOrEqual) ? value : null);
  return whereInfo;
}

OrderByInfo orderByInfoFromJsonMap(Map<String, dynamic> map) {
  var orderByInfo = new OrderByInfo();
  orderByInfo.fieldPath = map['fieldPath'] as String;
  orderByInfo.ascending = map['direction'] as String != orderByDescending;
  return orderByInfo;
}

Map<String, dynamic> whereInfoToJsonMap(WhereInfo whereInfo) {
  var map = <String, dynamic>{'fieldPath': whereInfo.fieldPath};
  if (whereInfo.isEqualTo != null) {
    map['operator'] = operatorEqual;
    map['value'] = documentDataValueToJson(whereInfo.isEqualTo);
  } else if (whereInfo.isLessThanOrEqualTo != null) {
    map['operator'] = operatorLessThanOrEqual;
    map['value'] = documentDataValueToJson(whereInfo.isLessThanOrEqualTo);
  } else if (whereInfo.isLessThan != null) {
    map['operator'] = operatorLessThan;
    map['value'] = documentDataValueToJson(whereInfo.isLessThan);
  } else if (whereInfo.isGreaterThanOrEqualTo != null) {
    map['operator'] = operatorGreaterThanOrEqual;
    map['value'] = documentDataValueToJson(whereInfo.isGreaterThanOrEqualTo);
  } else if (whereInfo.isGreaterThan != null) {
    map['operator'] = operatorGreaterThan;
    map['value'] = documentDataValueToJson(whereInfo.isGreaterThan);
  } else if (whereInfo.isNull != null) {
    map['operator'] = operatorEqual;
    map['value'] = null;
  }
  return map;
}

Map<String, dynamic> orderByInfoToJsonMap(OrderByInfo orderByInfo) {
  var map = <String, dynamic>{
    'fieldPath': orderByInfo.fieldPath,
    "direction":
        orderByInfo.ascending == true ? orderByAscending : orderByDescending
  };
  return map;
}

Map<String, dynamic> limitInfoToJsonMap(LimitInfo limitInfo) {
  var map = <String, dynamic>{};
  if (limitInfo.inclusive == true) {
    map['inclusive'] = true;
  }
  if (limitInfo.values != null) {
    map['values'] = limitInfo.values
        .map((value) => documentDataValueToJson(value))
        .toList();
  }
  if (limitInfo.documentId != null) {
    map['documentId'] = limitInfo.documentId;
  }
  return map;
}

LimitInfo limitInfoFromJsonMap(Firestore firestore, Map<String, dynamic> map) {
  var limitInfo = new LimitInfo();
  if (map.containsKey('inclusive')) {
    limitInfo.inclusive = map['inclusive'] == true;
  }
  if (map.containsKey('values')) {
    limitInfo.values = (map['values'] as List)
        .map((value) => jsonToDocumentDataValue(firestore, value))
        .toList();
  } else if (map.containsKey('documentId')) {
    limitInfo.documentId = map['documentId'] as String;
  }
  return limitInfo;
}

Map<String, dynamic> queryInfoToJsonMap(QueryInfo queryInfo) {
  var map = <String, dynamic>{};
  if (queryInfo.limit != null) {
    map['limit'] = queryInfo.limit;
  }
  if (queryInfo.offset != null) {
    map['offset'] = queryInfo.offset;
  }
  if (queryInfo.wheres.isNotEmpty) {
    map['wheres'] = queryInfo.wheres
        .map((whereInfo) => whereInfoToJsonMap(whereInfo))
        .toList();
  }
  if (queryInfo.orderBys.isNotEmpty) {
    map['orderBys'] = queryInfo.orderBys
        .map((orderBy) => orderByInfoToJsonMap(orderBy))
        .toList();
  }
  if (queryInfo.selectKeyPaths != null) {
    map['selectKeyPaths'] = queryInfo.selectKeyPaths;
  }
  if (queryInfo.startLimit != null) {
    map['startLimit'] = limitInfoToJsonMap(queryInfo.startLimit);
  }
  if (queryInfo.endLimit != null) {
    map['endLimit'] = limitInfoToJsonMap(queryInfo.endLimit);
  }
  return map;
}

QueryInfo queryInfoFromJsonMap(Firestore firestore, Map<String, dynamic> map) {
  QueryInfo queryInfo = new QueryInfo();
  if (map.containsKey('limit')) {
    queryInfo.limit = map['limit'] as int;
  }
  if (map.containsKey('offset')) {
    queryInfo.offset = map['offset'] as int;
  }
  if (map.containsKey('wheres')) {
    queryInfo.wheres = (map['wheres'] as List)
        .map<WhereInfo>((map) =>
            whereInfoFromJsonMap(firestore, map as Map<String, dynamic>))
        .toList();
  }
  if (map.containsKey('orderBys')) {
    queryInfo.orderBys = (map['orderBys'] as List)
        .map<OrderByInfo>(
            (map) => orderByInfoFromJsonMap(map as Map<String, dynamic>))
        .toList();
  }
  if (map.containsKey('selectKeyPaths')) {
    queryInfo.selectKeyPaths = (map['selectKeyPaths'] as List).cast<String>();
  }
  if (map.containsKey('startLimit')) {
    queryInfo.startLimit = limitInfoFromJsonMap(
        firestore, map['startLimit'] as Map<String, dynamic>);
  }
  if (map.containsKey('endLimit')) {
    queryInfo.endLimit = limitInfoFromJsonMap(
        firestore, map['endLimit'] as Map<String, dynamic>);
  }
  return queryInfo;
}

const changeTypeAdded = "added";
const changeTypeModified = "modified";
const changeTypeRemoved = "removed";

DocumentChangeType documentChangeTypeFromString(String type) {
  // [:added:], [:removed:] or [:modified:]
  if (type == changeTypeAdded) {
    return DocumentChangeType.added;
  } else if (type == changeTypeRemoved) {
    return DocumentChangeType.removed;
  } else if (type == changeTypeModified) {
    return DocumentChangeType.modified;
  }
  return null;
}

String documentChangeTypeToString(DocumentChangeType type) {
  switch (type) {
    case DocumentChangeType.added:
      return changeTypeAdded;
    case DocumentChangeType.removed:
      return changeTypeRemoved;
    case DocumentChangeType.modified:
      return changeTypeModified;
  }
  return null;
}

String sanitizeReferencePath(String path) {
  if (path != null) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
  }
  return path;
}

bool isDocumentReferencePath(String path) {
  if (path == null) {
    return true;
  }
  var count = sanitizeReferencePath(path).split('/').length;
  return (count % 2) == 0;
}

abstract class WriteBatchBase implements WriteBatch {
  final List<WriteBatchOperation> operations = [];

  void delete(DocumentReference ref) =>
      operations.add(new WriteBatchOperationDelete(ref));

  @override
  void set(DocumentReference ref, Map<String, dynamic> data,
      [SetOptions options]) {
    operations
        .add(new WriteBatchOperationSet(ref, new DocumentData(data), options));
  }

  @override
  void update(DocumentReference ref, Map<String, dynamic> data) {
    operations.add(new WriteBatchOperationUpdate(ref, new DocumentData(data)));
  }
}

abstract class WriteBatchOperation {}

class WriteBatchOperationBase implements WriteBatchOperation {
  final DocumentReference docRef;

  WriteBatchOperationBase(this.docRef);
}

class WriteBatchOperationDelete extends WriteBatchOperationBase {
  WriteBatchOperationDelete(DocumentReference docRef) : super(docRef);
}

class WriteBatchOperationSet extends WriteBatchOperationBase {
  final DocumentData documentData;
  final SetOptions options;

  WriteBatchOperationSet(
      DocumentReference docRef, this.documentData, this.options)
      : super(docRef);
}

class WriteBatchOperationUpdate extends WriteBatchOperationBase {
  final DocumentData documentData;

  WriteBatchOperationUpdate(DocumentReference docRef, this.documentData)
      : super(docRef);
}
