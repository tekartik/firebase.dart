import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart' as impl;
import 'package:firebase_admin_interop/firebase_admin_interop.dart' as native;
import 'package:firebase_admin_interop/js.dart' as native show SetOptions;
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';

class FirestoreServiceNode implements FirestoreService {
  @override
  bool get supportsQuerySelect => true;
}

class FirestoreNode implements Firestore {
  final impl.Firestore nativeInstance;

  FirestoreNode(this.nativeInstance);

  @override
  CollectionReference collection(String path) =>
      _collectionReference(nativeInstance.collection(path));

  @override
  DocumentReference doc(String path) =>
      _wrapDocumentReference(nativeInstance.document(path));

  @override
  WriteBatch batch() => new WriteBatchNode(nativeInstance.batch());

  @override
  Future runTransaction(Function(Transaction transaction) updateFunction) {
    // TODO: implement runTransaction
    throw 'not implemented yet';
  }
}

FirestoreNode firestore(impl.Firestore _impl) =>
    _impl != null ? new FirestoreNode(_impl) : null;

CollectionReferenceNode _collectionReference(impl.CollectionReference _impl) =>
    _impl != null ? new CollectionReferenceNode._(_impl) : null;

DocumentReferenceNode _wrapDocumentReference(impl.DocumentReference _impl) =>
    _impl != null ? new DocumentReferenceNode._(_impl) : null;

native.DocumentReference _unwrapDocumentReference(DocumentReference docRef) =>
    (docRef as DocumentReferenceNode)?.nativeInstance;

class WriteBatchNode implements WriteBatch {
  final native.WriteBatch nativeInstance;

  WriteBatchNode(this.nativeInstance);

  @override
  Future commit() => nativeInstance.commit();

  @override
  void delete(DocumentReference ref) =>
      nativeInstance.delete(_unwrapDocumentReference(ref));

  @override
  void set(DocumentReference ref, Map<String, dynamic> data,
          [SetOptions options]) =>
      nativeInstance.setData(
          _unwrapDocumentReference(ref),
          documentDataToNativeDocumentData(new DocumentData(data)),
          _unwrapSetOptions(options));

  @override
  void update(DocumentReference ref, Map<String, dynamic> data) =>
      nativeInstance.updateData(_unwrapDocumentReference(ref),
          documentDataToNativeUpdateData(new DocumentData(data)));
}

class QueryNode extends Object with QueryMixin {
  final impl.DocumentQuery nativeInstance;

  QueryNode(this.nativeInstance);
}

abstract class QueryMixin implements Query {
  impl.DocumentQuery get nativeInstance;

  @override
  Future<QuerySnapshot> get() async =>
      _querySnapshot(await nativeInstance.get());

  @deprecated
  @override
  Query select(List<String> fieldPaths) =>
      _query(nativeInstance.select(fieldPaths));

  @override
  Query limit(int limit) => _query(nativeInstance.limit(limit));

  @override
  Query orderBy(String key, {bool descending}) =>
      _query(nativeInstance.orderBy(key, descending: descending == true));

  @override
  QueryNode startAt({DocumentSnapshot snapshot, List values}) =>
      _query(nativeInstance.startAt(
          snapshot: _nodeDocumentSnapshot(snapshot), values: values));

  @override
  Query startAfter({DocumentSnapshot snapshot, List values}) =>
      _query(nativeInstance.startAfter(
          snapshot: _nodeDocumentSnapshot(snapshot), values: values));

  @override
  QueryNode endAt({DocumentSnapshot snapshot, List values}) =>
      _query(nativeInstance.endAt(
          snapshot: _nodeDocumentSnapshot(snapshot), values: values));

  @override
  QueryNode endBefore({DocumentSnapshot snapshot, List values}) =>
      _query(nativeInstance.endBefore(
          snapshot: _nodeDocumentSnapshot(snapshot), values: values));

  @override
  QueryNode where(
    String fieldPath, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  }) =>
      _query(nativeInstance.where(fieldPath,
          isEqualTo: isEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isGreaterThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          isNull: isNull));

  @override
  Stream<QuerySnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (native.QuerySnapshot nativeQuerySnapshot,
            EventSink<QuerySnapshot> sink) {
      sink.add(_querySnapshot(nativeQuerySnapshot));
    });
    return nativeInstance.snapshots.transform(transformer);
  }
}

QueryNode _query(impl.DocumentQuery implQuery) =>
    implQuery != null ? new QueryNode(implQuery) : null;

class CollectionReferenceNode extends QueryNode implements CollectionReference {
  impl.CollectionReference get nativeInstance =>
      super.nativeInstance as impl.CollectionReference;

  CollectionReferenceNode._(impl.CollectionReference implCollectionReference)
      : super(implCollectionReference);

  @override
  DocumentReference doc([String path]) =>
      _wrapDocumentReference(nativeInstance.document(path));

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async =>
      _wrapDocumentReference(await nativeInstance
          .add(documentDataToNativeDocumentData(new DocumentData(data))));

  //@TODO immplement in firebase admin
  @override
  // ignore: invalid_use_of_protected_member
  String get id => nativeInstance.nativeInstance.id;

  @override
  DocumentReference get parent => _wrapDocumentReference(nativeInstance.parent);

  @override
  // ignore: invalid_use_of_protected_member
  String get path => nativeInstance.nativeInstance.path;
}

documentValueToNativeValue(dynamic value) {
  if (value == null ||
      value is num ||
      value is bool ||
      value is String ||
      value is DateTime) {
    return value;
  } else if (value is FieldValue) {
    if (value == FieldValue.delete) {
      return native.Firestore.fieldValues.delete();
    } else if (value == FieldValue.serverTimestamp) {
      return native.Firestore.fieldValues.serverTimestamp();
    }
  } else if (value is List) {
    return value.map((value) => documentValueToNativeValue(value)).toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) =>
        new MapEntry(key as String, documentValueToNativeValue(value)));
  } else if (value is DocumentReferenceNode) {
    return value.nativeInstance;
  } else if (value is GeoPoint) {
    return new native.GeoPoint(
        value.latitude?.toDouble(), value.longitude?.toDouble());
  } else if (value is Blob) {
    return new native.Blob.fromUint8List(value.data);
  } else {
    throw new ArgumentError.value(value, "${value.runtimeType}",
        "Unsupported value for documentValueToNativeValue");
  }
}

documentValueFromNativeValue(dynamic value) {
  if (value == null ||
      value is num ||
      value is bool ||
      value is String ||
      value is DateTime) {
    return value;
  } else if (value == native.Firestore.fieldValues.delete()) {
    return FieldValue.delete;
  } else if (value == native.Firestore.fieldValues.serverTimestamp()) {
    return FieldValue.serverTimestamp;
  } else if (value is List) {
    return value.map((value) => documentValueFromNativeValue(value)).toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) =>
        new MapEntry(key as String, documentValueFromNativeValue(value)));
  } else if (value is native.GeoPoint) {
    return new GeoPoint(value.latitude, value.longitude);
  } else if (value is native.Blob) {
    return new Blob(value.asUint8List());
  } else if (value is native.DocumentReference) {
    return new DocumentReferenceNode._(value);
  } else {
    throw new ArgumentError.value(value, "${value.runtimeType}",
        "Unsupported value for documentValueFromNativeValue");
  }
}

native.DocumentData documentDataToNativeDocumentData(
    DocumentData documentData) {
  if (documentData != null) {
    var map = (documentData as DocumentDataMap).map;
    var nativeMap = documentValueToNativeValue(map) as Map<String, dynamic>;
    native.DocumentData nativeInstance =
        new native.DocumentData.fromMap(nativeMap);
    return nativeInstance;
  }
  return null;
}

DocumentData documentDataFromNativeDocumentData(
    native.DocumentData nativeInstance) {
  if (nativeInstance != null) {
    var nativeMap = nativeInstance.toMap();
    var map = documentValueFromNativeValue(nativeMap) as Map<String, dynamic>;
    var documentData = new DocumentData(map);
    return documentData;
  }
  return null;
}

native.UpdateData documentDataToNativeUpdateData(DocumentData documentData) {
  if (documentData != null) {
    var map = (documentData as DocumentDataMap).map;
    var nativeMap = documentValueToNativeValue(map) as Map<String, dynamic>;
    native.UpdateData nativeInstance = new native.UpdateData.fromMap(nativeMap);
    return nativeInstance;
  }
  return null;
}

native.SetOptions _unwrapSetOptions(SetOptions options) => options != null
    ? new native.SetOptions(merge: options.merge == true)
    : null;

class DocumentReferenceNode implements DocumentReference {
  final impl.DocumentReference nativeInstance;

  DocumentReferenceNode._(this.nativeInstance);

  @override
  CollectionReference collection(path) =>
      _collectionReference(nativeInstance.collection(path));

  @override
  Future set(Map<String, dynamic> data, [SetOptions options]) async {
    await nativeInstance.setData(
        documentDataToNativeDocumentData(new DocumentData(data)),
        _unwrapSetOptions(options));
  }

  @override
  Future<DocumentSnapshot> get() async =>
      _documentSnapshot(await nativeInstance.get());

  @override
  Future delete() async {
    await nativeInstance.delete();
  }

  @override
  Future update(Map<String, dynamic> data) async {
    await nativeInstance
        .updateData(documentDataToNativeUpdateData(new DocumentData(data)));
  }

  @override
  String get id => nativeInstance.documentID;

  @override
  CollectionReference get parent =>
      _collectionReference(new impl.CollectionReference(
          // ignore: invalid_use_of_protected_member
          nativeInstance.nativeInstance.parent,
          nativeInstance.firestore));

  @override
  String get path => nativeInstance.path;

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (native.DocumentSnapshot nativeDocumentSnapshot,
            EventSink<DocumentSnapshot> sink) {
      sink.add(_documentSnapshot(nativeDocumentSnapshot));
    });
    return nativeInstance.snapshots.transform(transformer);
  }
}

class DocumentSnapshotNode implements DocumentSnapshot {
  final impl.DocumentSnapshot _impl;

  DocumentSnapshotNode._(this._impl);

  @override
  Map<String, dynamic> get data =>
      documentDataFromNativeDocumentData(_impl.data)?.asMap();

  @override
  DocumentReference get ref => _wrapDocumentReference(_impl.reference);

  @override
  bool get exists => _impl.exists;
}

DocumentChangeType _wrapDocumentChangeType(native.DocumentChangeType type) {
  switch (type) {
    case native.DocumentChangeType.added:
      return DocumentChangeType.added;
    case native.DocumentChangeType.removed:
      return DocumentChangeType.removed;
    case native.DocumentChangeType.modified:
      return DocumentChangeType.modified;
  }
  return null;
}

class DocumentChangeNode implements DocumentChange {
  final native.DocumentChange nativeInstance;

  DocumentChangeNode(this.nativeInstance);

  @override
  DocumentSnapshot get document => _documentSnapshot(nativeInstance.document);

  @override
  int get newIndex => nativeInstance.newIndex;

  @override
  int get oldIndex => nativeInstance.oldIndex;

  @override
  DocumentChangeType get type => _wrapDocumentChangeType(nativeInstance.type);
}

class QuerySnapshotNode implements QuerySnapshot {
  final impl.QuerySnapshot nativeInstance;

  QuerySnapshotNode._(this.nativeInstance);

  @override
  List<DocumentSnapshot> get docs {
    var implDocs = nativeInstance.documents;
    if (implDocs == null) {
      return null;
    }
    var docs = <DocumentSnapshot>[];
    for (var implDocumentSnapshot in implDocs) {
      docs.add(_documentSnapshot(implDocumentSnapshot));
    }
    return docs;
  }

  @override
  List<DocumentChange> get documentChanges {
    var changes = <DocumentChange>[];
    if (nativeInstance.documentChanges != null) {
      for (var nativeChange in nativeInstance.documentChanges) {
        changes.add(new DocumentChangeNode(nativeChange));
      }
    }
    return changes;
  }
}

DocumentSnapshotNode _documentSnapshot(impl.DocumentSnapshot _impl) =>
    _impl != null ? new DocumentSnapshotNode._(_impl) : null;

impl.DocumentSnapshot _nodeDocumentSnapshot(DocumentSnapshot snapshot) =>
    snapshot != null ? (snapshot as DocumentSnapshotNode)._impl : null;

QuerySnapshotNode _querySnapshot(impl.QuerySnapshot _impl) =>
    _impl != null ? new QuerySnapshotNode._(_impl) : null;
