import 'dart:async';

import 'package:firebase/firestore.dart' as native;
import 'package:js/js_util.dart';
import 'package:tekartik_browser_utils/browser_utils_import.dart' hide Blob;
import 'package:tekartik_firebase/src/firestore.dart';

class FirestoreServiceBrowser implements FirestoreService {
  @override
  bool get supportsQuerySelect => false;

  @override
  bool get supportsDocumentSnapshotTime => false;

  @override
  bool get supportsTimestampsInSnapshots => false;

  @override
  bool get supportsTimestamps => false;
}

class FirestoreBrowser implements Firestore {
  final native.Firestore nativeInstance;

  FirestoreBrowser(this.nativeInstance);

  @override
  CollectionReference collection(String path) =>
      _wrapCollectionReference(nativeInstance.collection(path));

  @override
  DocumentReference doc(String path) =>
      _wrapDocumentReference(nativeInstance.doc(path));

  @override
  WriteBatch batch() {
    var nativeBatch = nativeInstance.batch();
    return nativeBatch != null ? WriteBatchBrowser(nativeBatch) : null;
  }

  @override
  Future runTransaction(Function(Transaction transaction) updateFunction) =>
      nativeInstance.runTransaction((nativeTransaction) {
        var transaction = TransactionBrowser(nativeTransaction);
        return updateFunction(transaction);
      });

  @override
  void settings(FirestoreSettings settings) {
    // TODO: implement settings
  }
}

class WriteBatchBrowser implements WriteBatch {
  final native.WriteBatch nativeInstance;

  WriteBatchBrowser(this.nativeInstance);

  @override
  Future commit() => nativeInstance.commit();

  @override
  void delete(DocumentReference ref) =>
      nativeInstance.delete(_unwrapDocumentReference(ref));

  @override
  void set(DocumentReference ref, Map<String, dynamic> data,
      [SetOptions options]) {
    nativeInstance.set(_unwrapDocumentReference(ref),
        documentDataToNativeMap(DocumentData(data)), _unwrapOptions(options));
  }

  @override
  void update(DocumentReference ref, Map<String, dynamic> data) {
    nativeInstance.update(_unwrapDocumentReference(ref),
        data: documentDataToNativeMap(DocumentData(data)));
  }
}

class TransactionBrowser implements Transaction {
  final native.Transaction nativeInstance;

  TransactionBrowser(this.nativeInstance);
  @override
  void delete(DocumentReference documentRef) {
    nativeInstance.delete(_unwrapDocumentReference(documentRef));
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) async =>
      _wrapDocumentSnapshot(
          await nativeInstance.get(_unwrapDocumentReference(documentRef)));

  @override
  void set(DocumentReference documentRef, Map<String, dynamic> data,
      [SetOptions options]) {
    nativeInstance.set(_unwrapDocumentReference(documentRef),
        documentDataToNativeMap(DocumentData(data)), _unwrapOptions(options));
  }

  @override
  void update(DocumentReference documentRef, Map<String, dynamic> data) {
    nativeInstance.update(_unwrapDocumentReference(documentRef),
        data: documentDataToNativeMap(DocumentData(data)));
  }
}

CollectionReferenceBrowser _wrapCollectionReference(
    native.CollectionReference nativeCollectionReference) {
  return nativeCollectionReference != null
      ? CollectionReferenceBrowser(nativeCollectionReference)
      : null;
}

DocumentReferenceBrowser _wrapDocumentReference(
    native.DocumentReference nativeDocumentReference) {
  return nativeDocumentReference != null
      ? DocumentReferenceBrowser(nativeDocumentReference)
      : null;
}

// for both native and not
bool isCommonValue(value) {
  return (value == null ||
      value is String ||
      value is DateTime ||
      value is num ||
      value is bool);
}

dynamic fromNativeValue(nativeValue) {
  if (isCommonValue(nativeValue)) {
    return nativeValue;
  }
  if (nativeValue is Iterable) {
    return nativeValue
        .map((nativeValue) => fromNativeValue(nativeValue))
        .toList();
  } else if (nativeValue is Map) {
    return nativeValue.map<String, dynamic>((key, nativeValue) =>
        MapEntry(key as String, fromNativeValue(nativeValue)));
  } else if (native.FieldValue.delete() == nativeValue) {
    return FieldValue.delete;
  } else if (native.FieldValue.serverTimestamp() == nativeValue) {
    return FieldValue.serverTimestamp;
  } else if (nativeValue is native.DocumentReference) {
    return DocumentReferenceBrowser(nativeValue);
  } else if (_isNativeBlob(nativeValue)) {
    var nativeBlob = nativeValue as native.Blob;
    return Blob(nativeBlob.toUint8Array());
  } else if (_isNativeGeoPoint(nativeValue)) {
    var nativeGeoPoint = nativeValue as native.GeoPoint;
    return GeoPoint(nativeGeoPoint.latitude, nativeGeoPoint.longitude);
  } else {
    throw 'not supported ${nativeValue} type ${nativeValue.runtimeType}';
  }
}

bool _isNativeBlob(dynamic native) {
  // value [toBase64, toUint8Array, toString, isEqual, n]
  // devPrint("value ${objectKeys(getProperty(native, "__proto__"))}");
  var proto = getProperty(native, '__proto__');
  if (proto != null) {
    return hasProperty(proto, "toBase64") == true &&
        hasProperty(proto, "toUint8Array") == true;
  }
  return false;
}

bool _isNativeGeoPoint(dynamic native) {
  //  [latitude, longitude, isEqual, n]
  // devPrint("value ${objectKeys(getProperty(native, "__proto__"))}");
  var proto = getProperty(native, '__proto__');
  if (proto != null) {
    return hasProperty(proto, "latitude") == true &&
        hasProperty(proto, "longitude") == true;
  }
  return false;
}

dynamic toNativeValue(value) {
  if (isCommonValue(value)) {
    return value;
  } else if (value is Timestamp) {
    // Currently only DateTime are supported
    return value.toDateTime();
  } else if (value is Iterable) {
    return value.map((nativeValue) => toNativeValue(nativeValue)).toList();
  } else if (value is Map) {
    return value.map<String, dynamic>(
        (key, value) => MapEntry(key as String, toNativeValue(value)));
  } else if (value is FieldValue) {
    if (FieldValue.delete == value) {
      return native.FieldValue.delete();
    } else if (FieldValue.serverTimestamp == value) {
      return native.FieldValue.serverTimestamp();
    }
  } else if (value is DocumentReferenceBrowser) {
    return value.nativeInstance;
  } else if (value is Blob) {
    return native.Blob.fromUint8Array(value.data);
  } else if (value is GeoPoint) {
    return native.GeoPoint(value.latitude, value.longitude);
  }

  throw 'not supported ${value} type ${value.runtimeType}';
}

Map<String, dynamic> documentDataToNativeMap(DocumentData documentData) {
  if (documentData != null) {
    var map = (documentData as DocumentDataMap).map;
    return toNativeValue(map) as Map<String, dynamic>;
  }
  return null;
}

DocumentData documentDataFromNativeMap(Map<String, dynamic> nativeMap) {
  if (nativeMap != null) {
    var map = fromNativeValue(nativeMap) as Map<String, dynamic>;
    return DocumentData(map);
  }
  return null;
}

class DocumentSnapshotBrowser implements DocumentSnapshot {
  final native.DocumentSnapshot _native;

  DocumentSnapshotBrowser(this._native);

  @override
  Map<String, dynamic> get data =>
      documentDataFromNativeMap(_native.data())?.asMap();

  @override
  bool get exists => _native.exists;

  @override
  DocumentReference get ref => _wrapDocumentReference(_native.ref);

  // Not supported for browser
  @override
  Timestamp get updateTime => null;

  // Not supported for browser
  @override
  Timestamp get createTime => null;
}

native.SetOptions _unwrapOptions(SetOptions options) {
  native.SetOptions nativeOptions;
  if (options != null) {
    nativeOptions = native.SetOptions(merge: options.merge == true);
  }
  return nativeOptions;
}

native.DocumentReference _unwrapDocumentReference(DocumentReference ref) {
  return (ref as DocumentReferenceBrowser)?.nativeInstance;
}

class DocumentReferenceBrowser implements DocumentReference {
  final native.DocumentReference nativeInstance;

  DocumentReferenceBrowser(this.nativeInstance);

  @override
  CollectionReference collection(String path) =>
      _wrapCollectionReference(nativeInstance.collection(path));

  @override
  Future delete() => nativeInstance.delete();

  @override
  Future<DocumentSnapshot> get() async =>
      _wrapDocumentSnapshot(await nativeInstance.get());

  @override
  String get id => nativeInstance.id;

  @override
  CollectionReference get parent =>
      _wrapCollectionReference(nativeInstance.parent);

  @override
  String get path => nativeInstance.path;

  @override
  Future set(Map<String, dynamic> data, [SetOptions options]) async {
    await nativeInstance.set(
        documentDataToNativeMap(DocumentData(data)), _unwrapOptions(options));
  }

  @override
  Future update(Map<String, dynamic> data) =>
      nativeInstance.update(data: documentDataToNativeMap(DocumentData(data)));

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (native.DocumentSnapshot nativeDocumentSnapshot,
            EventSink<DocumentSnapshot> sink) {
      sink.add(_wrapDocumentSnapshot(nativeDocumentSnapshot));
    });
    return nativeInstance.onSnapshot.transform(transformer);
  }
}

DocumentSnapshotBrowser _wrapDocumentSnapshot(
        native.DocumentSnapshot _native) =>
    _native != null ? DocumentSnapshotBrowser(_native) : null;

native.DocumentSnapshot _unwrapDocumentSnapshot(
        DocumentSnapshot documentSnapshot) =>
    documentSnapshot != null
        ? (documentSnapshot as DocumentSnapshotBrowser)._native
        : null;

class QuerySnapshotBrowser implements QuerySnapshot {
  final native.QuerySnapshot _native;

  QuerySnapshotBrowser(this._native);

  @override
  List<DocumentSnapshot> get docs {
    var docs = <DocumentSnapshot>[];
    for (var _nativeDoc in _native.docs) {
      docs.add(_wrapDocumentSnapshot(_nativeDoc));
    }
    return docs;
  }

  @override
  List<DocumentChange> get documentChanges {
    var changes = <DocumentChange>[];
    if (_native.docChanges != null) {
      for (var nativeChange in _native.docChanges()) {
        changes.add(DocumentChangeBrowser(nativeChange));
      }
    }
    return changes;
  }
}

DocumentChangeType _wrapDocumentChangeType(String type) {
  // [:added:], [:removed:] or [:modified:]
  if (type == 'added') {
    return DocumentChangeType.added;
  } else if (type == 'removed') {
    return DocumentChangeType.removed;
  } else if (type == 'modified') {
    return DocumentChangeType.modified;
  }
  return null;
}

class DocumentChangeBrowser implements DocumentChange {
  final native.DocumentChange nativeInstance;

  DocumentChangeBrowser(this.nativeInstance);

  @override
  DocumentSnapshot get document => _wrapDocumentSnapshot(nativeInstance.doc);

  @override
  int get newIndex => nativeInstance.newIndex?.toInt();

  @override
  int get oldIndex => nativeInstance.oldIndex?.toInt();

  @override
  DocumentChangeType get type => _wrapDocumentChangeType(nativeInstance.type);
}

QuerySnapshotBrowser _wrapQuerySnapshot(native.QuerySnapshot _native) =>
    _native != null ? QuerySnapshotBrowser(_native) : null;

QueryBrowser _wrapQuery(native.Query native) =>
    native != null ? QueryBrowser(native) : null;

class QueryBrowser implements Query {
  final native.Query _native;

  QueryBrowser(this._native);

  @override
  Query endAt({DocumentSnapshot snapshot, List values}) => _wrapQuery(_native
      .endAt(snapshot: _unwrapDocumentSnapshot(snapshot), fieldValues: values));

  @override
  Query endBefore({DocumentSnapshot snapshot, List values}) =>
      _wrapQuery(_native.endBefore(
          snapshot: _unwrapDocumentSnapshot(snapshot), fieldValues: values));

  @override
  Future<QuerySnapshot> get() async => _wrapQuerySnapshot(await _native.get());

  @override
  Query limit(int limit) => _wrapQuery(_native.limit(limit));

  @override
  Query orderBy(String key, {bool descending}) =>
      _wrapQuery(_native.orderBy(key, descending == true ? 'desc' : null));

  @override
  Query select(List<String> keyPaths) => this; // not supported

  @override
  Query startAfter({DocumentSnapshot snapshot, List values}) =>
      _wrapQuery(_native.startAfter(
          snapshot: _unwrapDocumentSnapshot(snapshot), fieldValues: values));

  @override
  Query startAt({DocumentSnapshot snapshot, List values}) =>
      _wrapQuery(_native.startAt(
          snapshot: _unwrapDocumentSnapshot(snapshot), fieldValues: values));

  @override
  Query where(String fieldPath,
      {isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      arrayContains,
      bool isNull}) {
    String opStr;
    dynamic value;
    if (isEqualTo != null) {
      opStr = '==';
      value = isEqualTo;
    }
    if (isLessThan != null) {
      assert(opStr == null);
      opStr = '<';
      value = isLessThan;
    }
    if (isLessThanOrEqualTo != null) {
      assert(opStr == null);
      opStr = '<=';
      value = isLessThanOrEqualTo;
    }
    if (isGreaterThan != null) {
      assert(opStr == null);
      opStr = '>';
      value = isGreaterThan;
    }
    if (isGreaterThanOrEqualTo != null) {
      assert(opStr == null);
      opStr = '>=';
      value = isGreaterThanOrEqualTo;
    }
    if (isNull != null) {
      assert(opStr == null);
      opStr = '==';
      value = null;
    }
    if (arrayContains != null) {
      assert(opStr == null);
      opStr = 'array-contains';
      value = arrayContains;
    }
    return _wrapQuery(_native.where(fieldPath, opStr, value));
  }

  @override
  Stream<QuerySnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (native.QuerySnapshot nativeQuerySnapshot,
            EventSink<QuerySnapshot> sink) {
      sink.add(_wrapQuerySnapshot(nativeQuerySnapshot));
    });
    //new StreamController<QuerySnapshot>();
    return _native.onSnapshot.transform(transformer);
  }
}

class CollectionReferenceBrowser extends QueryBrowser
    implements CollectionReference {
  native.CollectionReference get _nativeCollectionReference =>
      _native as native.CollectionReference;

  CollectionReferenceBrowser(
      native.CollectionReference nativeCollectionReference)
      : super(nativeCollectionReference);

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async =>
      _wrapDocumentReference(await _nativeCollectionReference
          .add(documentDataToNativeMap(DocumentData(data))));

  @override
  DocumentReference doc([String path]) =>
      _wrapDocumentReference(_nativeCollectionReference.doc(path));

  @override
  String get id => _nativeCollectionReference.id;

  @override
  DocumentReference get parent =>
      _wrapDocumentReference(_nativeCollectionReference.parent);

  @override
  String get path => _nativeCollectionReference.path;
}
