import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
export 'package:tekartik_firebase/src/firestore.dart'
    show Timestamp, FirestoreSettings;

abstract class FirestoreService {
  bool get supportsQuerySelect;
  bool get supportsDocumentSnapshotTime;
  bool get supportsTimestamps;
  bool get supportsTimestampsInSnapshots;
}

/// Represents a Firestore Database and is the entry point for all
/// Firestore operations.
abstract class Firestore {
  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path);

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference doc(String path);

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  WriteBatch batch();

  /// Executes the given [updateFunction] and commits the changes applied within
  /// the transaction.
  ///
  /// You can use the transaction object passed to [updateFunction] to read and
  /// modify Firestore documents under lock. Transactions are committed once
  /// [updateFunction] resolves and attempted up to five times on failure.
  ///
  /// Returns the same `Future` returned by [updateFunction] if transaction
  /// completed successfully of was explicitly aborted by returning a Future
  /// with an error. If [updateFunction] throws then returned Future completes
  /// with the same error.
  Future runTransaction(updateFunction(Transaction transaction));

  /// Specifies custom settings to be used to configure the `Firestore`
  /// instance.
  ///
  /// Can only be invoked once and before any other [Firestore] method.
  void settings(FirestoreSettings settings);
}

abstract class CollectionReference extends Query {
  String get path;

  String get id;

  DocumentReference get parent;

  DocumentReference doc([String path]);

  Future<DocumentReference> add(Map<String, dynamic> data);
}

abstract class DocumentReference {
  String get id;

  String get path;

  CollectionReference get parent;

  CollectionReference collection(String path);

  Future delete();

  Future<DocumentSnapshot> get();

  Future set(Map<String, dynamic> data, [SetOptions options]);

  Future update(Map<String, dynamic> data);

  Stream<DocumentSnapshot> onSnapshot();
}

abstract class DocumentData {
  factory DocumentData([Map<String, dynamic> map]) => DocumentDataMap(map: map);

  void setString(String key, String value);

  String getString(String key);

  void setNull(String key);

  void setFieldValue(String key, FieldValue value);

  void setInt(String key, int value);

  int getInt(String key);

  void setNum(String key, num value);

  void setBool(String key, bool value);

  num getNum(String key);

  bool getBool(String key);

  void setDateTime(String key, DateTime value);

  DateTime getDateTime(String key);

  void setTimestamp(String key, Timestamp value);

  Timestamp getTimestamp(String key);

  void setList<T>(String key, List<T> list);

  List<T> getList<T>(String key);

  DocumentData getData(String key);

  void setData(String key, DocumentData value);

  // Return the native property
  dynamic getProperty(String key);

  // Set the native property
  void setProperty(String key, dynamic value);

  // Check the native property
  bool has(String key);

  // Return the key list
  Iterable<String> get keys;

  Map<String, dynamic> asMap();

  // use hasProperty
  @deprecated
  bool containsKey(String key);

  // Document reference
  void setDocumentReference(String key, DocumentReference doc);

  // Document reference
  DocumentReference getDocumentReference(String key);

  // blob
  void setBlob(String key, Blob blob);

  Blob getBlob(String key);

  void setGeoPoint(String key, GeoPoint geoPoint);

  GeoPoint getGeoPoint(String key);
}

abstract class DocumentSnapshot {
  DocumentReference get ref;

  Map<String, dynamic> get data;

  bool get exists;

  /// The time the document was last updated (at the time the snapshot was
  /// generated). Not set for documents that don't exist.
  Timestamp get updateTime;

  /// The time the document was created. Not set for documents that don't
  /// exist.
  Timestamp get createTime;
}

// Sentinal values for update/set
enum FieldValue {
  serverTimestamp,
// update only
  delete
}

// Use UInt8Array as much as possible
class Blob {
  final Uint8List _data;

  Blob.fromList(List<int> data) : _data = Uint8List.fromList(data);

  Uint8List get data => _data;

  Blob(this._data);

  @override
  int get hashCode =>
      (_data != null && _data.length > 0) ? _data.first.hashCode : 0;

  @override
  bool operator ==(other) {
    if (other is Blob) {
      return const ListEquality().equals(other.data, _data);
    }
    return false;
  }

  @override
  String toString() {
    return base64.encode(data);
  }
}

class GeoPoint {
  final num latitude;
  final num longitude;

  GeoPoint(this.latitude, this.longitude);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! GeoPoint) return false;
    GeoPoint point = other;
    return latitude == point.latitude && longitude == point.longitude;
  }

  @override
  int get hashCode =>
      (latitude != null ? latitude.hashCode : 0) * 17 + longitude != null
          ? longitude.hashCode
          : 0;

  @override
  String toString() => "[$latitude° N, $longitude° E]";
}

class SetOptions {
  /// Set to true to replace only the values from the new data.
  /// Fields omitted will remain untouched.
  bool merge;

  SetOptions({this.merge});
}

const String operatorEqual = '=';
const String operatorLessThan = '<';
const String operatorGreaterThan = '>';
const String operatorLessThanOrEqual = '<=';
const String operatorGreaterThanOrEqual = '>=';
const String opeatorArrayContains = 'array-contains';

const orderByAscending = "asc";
const orderByDescending = "desc";

abstract class WriteBatch {
  void delete(DocumentReference ref);

  void set(DocumentReference ref, Map<String, dynamic> data,
      [SetOptions options]);

  void update(DocumentReference ref, Map<String, dynamic> data);

  Future commit();
}

abstract class QuerySnapshot {
  List<DocumentSnapshot> get docs;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<DocumentChange> get documentChanges;
}

/// An enumeration of document change types.
enum DocumentChangeType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed,
}

/// A DocumentChange represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
abstract class DocumentChange {
  /// The type of change that occurred (added, modified, or removed).
  ///
  /// Can be `null` if this document change was returned from [DocumentQuery.get].
  DocumentChangeType get type;

  /// The index of the changed document in the result set immediately prior to
  /// this [DocumentChange] (i.e. supposing that all prior DocumentChange objects
  /// have been applied).
  ///
  /// -1 for [DocumentChangeType.added] events.
  int get oldIndex;

  /// The index of the changed document in the result set immediately after this
  /// DocumentChange (i.e. supposing that all prior [DocumentChange] objects
  /// and the current [DocumentChange] object have been applied).
  ///
  /// -1 for [DocumentChangeType.removed] events.
  int get newIndex;

  /// The document affected by this change.
  DocumentSnapshot get document;
}

abstract class Query {
  Future<QuerySnapshot> get();

  Stream<QuerySnapshot> onSnapshot();

  Query limit(int limit);

  Query orderBy(String key, {bool descending});

  Query select(List<String> keyPaths);

  // Query offset(int offset);

  Query startAt({DocumentSnapshot snapshot, List values});

  Query startAfter({DocumentSnapshot snapshot, List<dynamic> values});

  Query endAt({DocumentSnapshot snapshot, List values});

  Query endBefore({DocumentSnapshot snapshot, List values});

  Query where(
    String fieldPath, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    bool isNull,
  });
}

// get must be done first
abstract class Transaction {
  /// Deletes the document referred to by the provided [DocumentReference].
  ///
  /// The [DocumentReference] parameter is a reference to the document to be
  /// deleted. Value must not be null.
  void delete(DocumentReference documentRef);

  /// Reads the document referenced by the provided [DocumentReference].
  ///
  /// The [DocumentReference] parameter is a reference to the document to be
  /// retrieved. Value must not be null.
  ///
  /// Returns non-null [Future] of the read data in a [DocumentSnapshot].
  Future<DocumentSnapshot> get(DocumentReference documentRef);

  /// Writes to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created.
  /// If you pass [options], the provided data can be merged into the existing
  /// document.
  ///
  /// The [DocumentReference] parameter is a reference to the document to be
  /// created. Value must not be null.
  ///
  /// The [data] paramater is object of the fields and values for
  /// the document. Value must not be null.
  ///
  /// The optional [SetOptions] is an object to configure the set behavior.
  /// Pass [: {merge: true} :] to only replace the values specified in the
  /// data argument. Fields omitted will remain untouched.
  /// Value must not be null.
  void set(DocumentReference documentRef, Map<String, dynamic> data,
      [SetOptions options]);

  /// Updates fields in the document referred to by this [DocumentReference].
  /// The update will fail if applied to a document that does not exist.
  /// The value must not be null.
  ///
  /// Nested fields can be updated by providing dot-separated field path strings
  /// or by providing [FieldPath] objects.
  ///
  /// The [data] param is the object containing all of the fields and values
  /// to update.
  ///
  /// The [fieldsAndValues] param is the List alternating between fields
  /// (as String or [FieldPath] objects) and values.
  void update(DocumentReference documentRef, Map<String, dynamic> data);
}

DateTime toLocaleTime(DateTime value) {
  if (value == null || !value.isUtc) {
    return value;
  }
  return value.toLocal();
}

DateTime parseDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  } else {
    return parseTimestamp(value)?.toDateTime();
  }
}

Timestamp parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value;
  } else if (value is DateTime) {
    return Timestamp.fromDateTime(value);
  } else if (value is String) {
    String text = value;
    return Timestamp.tryParse(text);
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

  @override
  Timestamp getTimestamp(String key) {
    return parseTimestamp(getValue(key));
  }

  @override
  void setTimestamp(String key, Timestamp value) {
    setValue(key, value);
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

class FirestoreSettings {
  /// Enables the use of `Timestamp`s for timestamp fields in
  /// `DocumentSnapshot`s.
  final bool timestampsInSnapshots;

  FirestoreSettings({this.timestampsInSnapshots});

  @override
  String toString() {
    var map = {'timestampsInSnapshots': timestampsInSnapshots};
    return map.toString();
  }
}
