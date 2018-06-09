import 'dart:async';
import 'dart:typed_data';

import 'src/firestore.dart';

abstract class FirestoreService {
  bool get supportsQuerySelect;
}

abstract class Firestore {
  CollectionReference collection(String path);

  DocumentReference doc(String path);

  WriteBatch batch();

  Future runTransaction(updateFunction(Transaction transaction));
}

abstract class CollectionReference extends Query {
  String get path;

  String get id;

  DocumentReference get parent;

  DocumentReference doc([String path]);

  Future<DocumentReference> add(DocumentData documentData);
}

abstract class DocumentReference {
  String get id;

  String get path;

  CollectionReference get parent;

  CollectionReference collection(String path);

  Future delete();

  //Future<WriteResult> create(DocumentData documentData);

  Future<DocumentSnapshot> get();

  Future set(DocumentData documentData, [SetOptions options]);

  Future update(DocumentData documentData);

  Stream<DocumentSnapshot> onSnapshot();
}

abstract class DocumentData {
  factory DocumentData([Map<String, dynamic> map]) =>
      new DocumentDataMap(map: map);

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

  Map<String, dynamic> toMap();

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

  DocumentData data();

  bool get exists;
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

  Blob.fromList(List<int> data) : _data = new Uint8List.fromList(data);
  Uint8List get data => _data;

  Blob(this._data);
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

const orderByAscending = "asc";
const orderByDescending = "desc";

abstract class WriteBatch {
  void delete(DocumentReference ref);
  void set(DocumentReference ref, DocumentData documentData,
      [SetOptions options]);
  void update(DocumentReference ref, DocumentData documentData);
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
  void set(DocumentReference documentRef, DocumentData data,
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
  void update(DocumentReference documentRef, DocumentData data);
}
