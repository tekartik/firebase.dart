import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart' as node;
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';

class FirestoreServiceNode implements FirestoreService {
  @override
  bool get supportsQuerySelect => true;

  @override
  bool get supportsDocumentSnapshotTime => true;
}

class FirestoreNode implements Firestore {
  final node.Firestore nativeInstance;

  FirestoreNode(this.nativeInstance);

  @override
  CollectionReference collection(String path) =>
      _collectionReference(nativeInstance.collection(path));

  @override
  DocumentReference doc(String path) =>
      _wrapDocumentReference(nativeInstance.document(path));

  @override
  WriteBatch batch() => WriteBatchNode(nativeInstance.batch());

  @override
  Future runTransaction(Function(Transaction transaction) updateFunction) =>
      nativeInstance.runTransaction((nativeTransaction) async {
        var transaction = TransactionNode(nativeTransaction);
        return await updateFunction(transaction);
      });
}

FirestoreNode firestore(node.Firestore _impl) =>
    _impl != null ? FirestoreNode(_impl) : null;

CollectionReferenceNode _collectionReference(node.CollectionReference _impl) =>
    _impl != null ? CollectionReferenceNode._(_impl) : null;

DocumentReferenceNode _wrapDocumentReference(node.DocumentReference _impl) =>
    _impl != null ? DocumentReferenceNode._(_impl) : null;

node.DocumentReference _unwrapDocumentReference(DocumentReference docRef) =>
    (docRef as DocumentReferenceNode)?.nativeInstance;

class WriteBatchNode implements WriteBatch {
  final node.WriteBatch nativeInstance;

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
          documentDataToNativeDocumentData(DocumentData(data)),
          _unwrapSetOptions(options));

  @override
  void update(DocumentReference ref, Map<String, dynamic> data) =>
      nativeInstance.updateData(_unwrapDocumentReference(ref),
          documentDataToNativeUpdateData(DocumentData(data)));
}

class QueryNode extends Object with QueryMixin {
  final node.DocumentQuery nativeInstance;

  QueryNode(this.nativeInstance);
}

abstract class QueryMixin implements Query {
  node.DocumentQuery get nativeInstance;

  @override
  Future<QuerySnapshot> get() async =>
      _wrapQuerySnapshot(await nativeInstance.get());

  @deprecated
  @override
  Query select(List<String> fieldPaths) =>
      _wrapQuery(nativeInstance.select(fieldPaths));

  @override
  Query limit(int limit) => _wrapQuery(nativeInstance.limit(limit));

  @override
  Query orderBy(String key, {bool descending}) =>
      _wrapQuery(nativeInstance.orderBy(key, descending: descending == true));

  @override
  QueryNode startAt({DocumentSnapshot snapshot, List values}) =>
      _wrapQuery(nativeInstance.startAt(
          snapshot: _unwrapDocumentSnapshot(snapshot), values: values));

  @override
  Query startAfter({DocumentSnapshot snapshot, List values}) =>
      _wrapQuery(nativeInstance.startAfter(
          snapshot: _unwrapDocumentSnapshot(snapshot), values: values));

  @override
  QueryNode endAt({DocumentSnapshot snapshot, List values}) =>
      _wrapQuery(nativeInstance.endAt(
          snapshot: _unwrapDocumentSnapshot(snapshot), values: values));

  @override
  QueryNode endBefore({DocumentSnapshot snapshot, List values}) =>
      _wrapQuery(nativeInstance.endBefore(
          snapshot: _unwrapDocumentSnapshot(snapshot), values: values));

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
      _wrapQuery(nativeInstance.where(fieldPath,
          isEqualTo: isEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isGreaterThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          isNull: isNull));

  @override
  Stream<QuerySnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (node.QuerySnapshot nativeQuerySnapshot,
            EventSink<QuerySnapshot> sink) {
      sink.add(_wrapQuerySnapshot(nativeQuerySnapshot));
    });
    return nativeInstance.snapshots.transform(transformer);
  }
}

class CollectionReferenceNode extends QueryNode implements CollectionReference {
  node.CollectionReference get nativeInstance =>
      super.nativeInstance as node.CollectionReference;

  CollectionReferenceNode._(node.CollectionReference implCollectionReference)
      : super(implCollectionReference);

  @override
  DocumentReference doc([String path]) =>
      _wrapDocumentReference(nativeInstance.document(path));

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async =>
      _wrapDocumentReference(await nativeInstance
          .add(documentDataToNativeDocumentData(DocumentData(data))));

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
      return node.Firestore.fieldValues.delete();
    } else if (value == FieldValue.serverTimestamp) {
      return node.Firestore.fieldValues.serverTimestamp();
    }
  } else if (value is List) {
    return value.map((value) => documentValueToNativeValue(value)).toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) =>
        MapEntry(key as String, documentValueToNativeValue(value)));
  } else if (value is DocumentReferenceNode) {
    return value.nativeInstance;
  } else if (value is GeoPoint) {
    return node.GeoPoint(
        value.latitude?.toDouble(), value.longitude?.toDouble());
  } else if (value is Blob) {
    return node.Blob.fromUint8List(value.data);
  } else {
    throw ArgumentError.value(value, "${value.runtimeType}",
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
  } else if (value == node.Firestore.fieldValues.delete()) {
    return FieldValue.delete;
  } else if (value == node.Firestore.fieldValues.serverTimestamp()) {
    return FieldValue.serverTimestamp;
  } else if (value is List) {
    return value.map((value) => documentValueFromNativeValue(value)).toList();
  } else if (value is Map) {
    return value.map<String, dynamic>((key, value) =>
        MapEntry(key as String, documentValueFromNativeValue(value)));
  } else if (value is node.GeoPoint) {
    return GeoPoint(value.latitude, value.longitude);
  } else if (value is node.Blob) {
    return Blob(value.asUint8List());
  } else if (value is node.DocumentReference) {
    return DocumentReferenceNode._(value);
  } else {
    throw ArgumentError.value(value, "${value.runtimeType}",
        "Unsupported value for documentValueFromNativeValue");
  }
}

node.DocumentData documentDataToNativeDocumentData(DocumentData documentData) {
  if (documentData != null) {
    var map = (documentData as DocumentDataMap).map;
    var nativeMap = documentValueToNativeValue(map) as Map<String, dynamic>;
    node.DocumentData nativeInstance = node.DocumentData.fromMap(nativeMap);
    return nativeInstance;
  }
  return null;
}

DocumentData documentDataFromNativeDocumentData(
    node.DocumentData nativeInstance) {
  if (nativeInstance != null) {
    var nativeMap = nativeInstance.toMap();
    var map = documentValueFromNativeValue(nativeMap) as Map<String, dynamic>;
    var documentData = DocumentData(map);
    return documentData;
  }
  return null;
}

node.UpdateData documentDataToNativeUpdateData(DocumentData documentData) {
  if (documentData != null) {
    var map = (documentData as DocumentDataMap).map;
    var nativeMap = documentValueToNativeValue(map) as Map<String, dynamic>;
    node.UpdateData nativeInstance = node.UpdateData.fromMap(nativeMap);
    return nativeInstance;
  }
  return null;
}

class DocumentReferenceNode implements DocumentReference {
  final node.DocumentReference nativeInstance;

  DocumentReferenceNode._(this.nativeInstance);

  @override
  CollectionReference collection(path) =>
      _collectionReference(nativeInstance.collection(path));

  @override
  Future set(Map<String, dynamic> data, [SetOptions options]) async {
    await nativeInstance.setData(
        documentDataToNativeDocumentData(DocumentData(data)),
        _unwrapSetOptions(options));
  }

  @override
  Future<DocumentSnapshot> get() async =>
      _wrapDocumentSnapshot(await nativeInstance.get());

  @override
  Future delete() async {
    await nativeInstance.delete();
  }

  @override
  Future update(Map<String, dynamic> data) async {
    await nativeInstance
        .updateData(documentDataToNativeUpdateData(DocumentData(data)));
  }

  @override
  String get id => nativeInstance.documentID;

  @override
  CollectionReference get parent =>
      _collectionReference(node.CollectionReference(
          // ignore: invalid_use_of_protected_member
          nativeInstance.nativeInstance.parent,
          nativeInstance.firestore));

  @override
  String get path => nativeInstance.path;

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (node.DocumentSnapshot nativeDocumentSnapshot,
            EventSink<DocumentSnapshot> sink) {
      sink.add(_wrapDocumentSnapshot(nativeDocumentSnapshot));
    });
    return nativeInstance.snapshots.transform(transformer);
  }
}

class DocumentSnapshotNode implements DocumentSnapshot {
  final node.DocumentSnapshot nativeInstance;

  DocumentSnapshotNode._(this.nativeInstance);

  @override
  Map<String, dynamic> get data =>
      documentDataFromNativeDocumentData(nativeInstance.data)?.asMap();

  @override
  DocumentReference get ref => _wrapDocumentReference(nativeInstance.reference);

  @override
  bool get exists => nativeInstance.exists;

  @override
  Timestamp get updateTime => _wrapTimestamp(nativeInstance.updateTime);

  @override
  Timestamp get createTime => _wrapTimestamp(nativeInstance.createTime);
}

Timestamp _wrapTimestamp(node.Timestamp nativeInstance) =>
    nativeInstance != null
        ? Timestamp(nativeInstance.seconds, nativeInstance.nanoseconds)
        : null;

DocumentChangeType _wrapDocumentChangeType(node.DocumentChangeType type) {
  switch (type) {
    case node.DocumentChangeType.added:
      return DocumentChangeType.added;
    case node.DocumentChangeType.removed:
      return DocumentChangeType.removed;
    case node.DocumentChangeType.modified:
      return DocumentChangeType.modified;
  }
  return null;
}

class DocumentChangeNode implements DocumentChange {
  final node.DocumentChange nativeInstance;

  DocumentChangeNode(this.nativeInstance);

  @override
  DocumentSnapshot get document =>
      _wrapDocumentSnapshot(nativeInstance.document);

  @override
  int get newIndex => nativeInstance.newIndex;

  @override
  int get oldIndex => nativeInstance.oldIndex;

  @override
  DocumentChangeType get type => _wrapDocumentChangeType(nativeInstance.type);
}

class QuerySnapshotNode implements QuerySnapshot {
  final node.QuerySnapshot nativeInstance;

  QuerySnapshotNode._(this.nativeInstance);

  @override
  List<DocumentSnapshot> get docs {
    var implDocs = nativeInstance.documents;
    if (implDocs == null) {
      return null;
    }
    var docs = <DocumentSnapshot>[];
    for (var implDocumentSnapshot in implDocs) {
      docs.add(_wrapDocumentSnapshot(implDocumentSnapshot));
    }
    return docs;
  }

  @override
  List<DocumentChange> get documentChanges {
    var changes = <DocumentChange>[];
    if (nativeInstance.documentChanges != null) {
      for (var nativeChange in nativeInstance.documentChanges) {
        changes.add(DocumentChangeNode(nativeChange));
      }
    }
    return changes;
  }
}

class TransactionNode implements Transaction {
  final node.Transaction nativeInstance;

  TransactionNode(this.nativeInstance);
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
        documentDataToNativeDocumentData(DocumentData(data)),
        merge: options?.merge ?? false);
  }

  @override
  void update(DocumentReference documentRef, Map<String, dynamic> data) {
    nativeInstance.update(_unwrapDocumentReference(documentRef),
        documentDataToNativeUpdateData(DocumentData(data)));
  }
}

QueryNode _wrapQuery(node.DocumentQuery nativeInstance) =>
    nativeInstance != null ? QueryNode(nativeInstance) : null;

DocumentSnapshotNode _wrapDocumentSnapshot(
        node.DocumentSnapshot nativeInstance) =>
    nativeInstance != null ? DocumentSnapshotNode._(nativeInstance) : null;

node.DocumentSnapshot _unwrapDocumentSnapshot(DocumentSnapshot snapshot) =>
    snapshot != null ? (snapshot as DocumentSnapshotNode).nativeInstance : null;

QuerySnapshotNode _wrapQuerySnapshot(node.QuerySnapshot nativeInstance) =>
    nativeInstance != null ? QuerySnapshotNode._(nativeInstance) : null;

node.SetOptions _unwrapSetOptions(SetOptions options) =>
    options != null ? node.SetOptions(merge: options.merge == true) : null;
