import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as native;
import 'package:tekartik_firebase/firestore.dart';

class FirestoreFlutter implements Firestore {
  final native.Firestore nativeInstance;

  FirestoreFlutter(this.nativeInstance);

  @override
  WriteBatch batch() => new WriteBatchFlutter(nativeInstance.batch());

  @override
  CollectionReference collection(String path) =>
      _wrapCollectionReference(nativeInstance.collection(path));

  @override
  DocumentReference doc(String path) =>
      _wrapDocumentReference(nativeInstance.document(path));

  @override
  Future runTransaction(Function(Transaction transaction) updateFunction) {
    return nativeInstance.runTransaction((nativeTransaction) {
      var transaction = new TransactionFlutter(nativeTransaction);
      return updateFunction(transaction);
    });
  }
}

class TransactionFlutter implements Transaction {
  final native.Transaction nativeInstance;

  TransactionFlutter(this.nativeInstance);

  @override
  void delete(DocumentReference documentRef) {
    // ok to ignore the future here
    nativeInstance.delete(_unwrapDocumentReference(documentRef));
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) async =>
      _wrapDocumentSnapshot(
          await nativeInstance.get(_unwrapDocumentReference(documentRef)));

  @override
  void set(DocumentReference documentRef, DocumentData data,
      [SetOptions options]) {
    // Warning merge is not handle yet!
    nativeInstance.set(
        _unwrapDocumentReference(documentRef), documentDataToFlutterData(data));
  }

  @override
  void update(DocumentReference documentRef, DocumentData data) {
    nativeInstance.update(
        _unwrapDocumentReference(documentRef), documentDataToFlutterData(data));
  }
}

class WriteBatchFlutter implements WriteBatch {
  final native.WriteBatch nativeInstance;

  WriteBatchFlutter(this.nativeInstance);

  @override
  Future commit() => nativeInstance.commit();

  @override
  void delete(DocumentReference ref) =>
      nativeInstance.delete(_unwrapDocumentReference(ref));

  @override
  void set(DocumentReference ref, DocumentData documentData,
      [SetOptions options]) {
    nativeInstance.setData(
        _unwrapDocumentReference(ref), documentDataToFlutterData(documentData),
        merge: options?.merge == true);
  }

  @override
  void update(DocumentReference ref, DocumentData documentData) =>
      nativeInstance.updateData(_unwrapDocumentReference(ref),
          documentDataToFlutterData(documentData));
}

Map<String, dynamic> documentDataToFlutterData(DocumentData data) {
  // TODO
  return data.toMap();
}

DocumentData documentDataFromFlutterData(Map<String, dynamic> map) {
  // TODO
  return new DocumentData();
}

QueryFlutter _wrapQuery(native.Query nativeInstance) =>
    nativeInstance != null ? new QueryFlutter(nativeInstance) : null;

class QueryFlutter implements Query {
  final native.Query nativeInstance;

  QueryFlutter(this.nativeInstance);
  @override
  Query endAt({DocumentSnapshot snapshot, List values}) {
    return _wrapQuery(nativeInstance.endAt(values));
  }

  @override
  Query endBefore({DocumentSnapshot snapshot, List values}) {
    return _wrapQuery(nativeInstance.endBefore(values));
  }

  @override
  Future<QuerySnapshot> get() async =>
      _wrapQuerySnapshot(await nativeInstance.getDocuments());

  @override
  Query limit(int limit) {
    return _wrapQuery(nativeInstance.limit(limit));
  }

  @override
  Stream<QuerySnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (native.QuerySnapshot nativeQuerySnapshot,
            EventSink<QuerySnapshot> sink) {
      sink.add(_wrapQuerySnapshot(nativeQuerySnapshot));
    });
    return nativeInstance.snapshots().transform(transformer);
  }

  @override
  Query orderBy(String key, {bool descending}) {
    return _wrapQuery(nativeInstance.orderBy(key, descending: descending));
  }

  @override
  Query select(List<String> keyPaths) {
    // not supported
    return this;
  }

  @override
  Query startAfter({DocumentSnapshot snapshot, List values}) {
    return _wrapQuery(nativeInstance.startAfter(values));
  }

  @override
  Query startAt({DocumentSnapshot snapshot, List values}) {
    return _wrapQuery(nativeInstance.startAt(values));
  }

  @override
  Query where(String fieldPath,
      {isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      bool isNull}) {
    return _wrapQuery(nativeInstance.where(fieldPath,
        isEqualTo: isEqualTo,
        isLessThan: isLessThan,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull));
  }
}

class CollectionReferenceFlutter extends QueryFlutter
    implements CollectionReference {
  CollectionReferenceFlutter(native.CollectionReference nativeInstance)
      : super(nativeInstance);
  native.CollectionReference get nativeInstance =>
      super.nativeInstance as native.CollectionReference;

  @override
  Future<DocumentReference> add(DocumentData documentData) async =>
      _wrapDocumentReference(
          await nativeInstance.add(documentDataToFlutterData(documentData)));

  @override
  DocumentReference doc([String path]) {
    return _wrapDocumentReference(nativeInstance.document(path));
  }

  @override
  String get id => nativeInstance.id;

  @override
  DocumentReference get parent {
    // _wrapDocumentReference(nativeInstance.parent());
    throw 'bug issue in original';
  }

  @override
  String get path => nativeInstance.path;
}

native.DocumentReference _unwrapDocumentReference(DocumentReference ref) =>
    (ref as DocumentReferenceFlutter).nativeInstance;
CollectionReferenceFlutter _wrapCollectionReference(
        native.CollectionReference nativeInstance) =>
    nativeInstance != null
        ? new CollectionReferenceFlutter(nativeInstance)
        : null;
DocumentReferenceFlutter _wrapDocumentReference(
        native.DocumentReference nativeInstance) =>
    nativeInstance != null
        ? new DocumentReferenceFlutter(nativeInstance)
        : null;
QuerySnapshotFlutter _wrapQuerySnapshot(native.QuerySnapshot nativeInstance) =>
    nativeInstance != null ? new QuerySnapshotFlutter(nativeInstance) : null;
DocumentSnapshotFlutter _wrapDocumentSnapshot(
        native.DocumentSnapshot nativeInstance) =>
    nativeInstance != null ? new DocumentSnapshotFlutter(nativeInstance) : null;
DocumentChangeFlutter _wrapDocumentChange(
        native.DocumentChange nativeInstance) =>
    nativeInstance != null ? new DocumentChangeFlutter(nativeInstance) : null;
DocumentChangeType _wrapDocumentChangeType(
    native.DocumentChangeType nativeInstance) {
  switch (nativeInstance) {
    case native.DocumentChangeType.added:
      return DocumentChangeType.added;
    case native.DocumentChangeType.modified:
      return DocumentChangeType.modified;
    case native.DocumentChangeType.removed:
      return DocumentChangeType.removed;
  }
  return null;
}

class DocumentReferenceFlutter implements DocumentReference {
  final native.DocumentReference nativeInstance;

  DocumentReferenceFlutter(this.nativeInstance);
  @override
  CollectionReference collection(String path) =>
      _wrapCollectionReference(nativeInstance.collection(path));

  @override
  Future delete() => nativeInstance.delete();

  @override
  Future<DocumentSnapshot> get() async =>
      _wrapDocumentSnapshot(await nativeInstance.get());

  @override
  String get id => nativeInstance.documentID;

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    var transformer = StreamTransformer.fromHandlers(handleData:
        (native.DocumentSnapshot nativeDocumentSnapshot,
            EventSink<DocumentSnapshot> sink) {
      sink.add(_wrapDocumentSnapshot(nativeDocumentSnapshot));
    });
    return nativeInstance.snapshots().transform(transformer);
  }

  // TODO: implement parent
  @override
  CollectionReference get parent => throw 'bug in parent';

  @override
  String get path => nativeInstance.path;

  @override
  Future set(DocumentData documentData, [SetOptions options]) =>
      nativeInstance.setData(documentDataToFlutterData(documentData),
          merge: options?.merge == true);

  @override
  Future update(DocumentData documentData) =>
      nativeInstance.updateData(documentDataToFlutterData(documentData));
}

class DocumentSnapshotFlutter implements DocumentSnapshot {
  final native.DocumentSnapshot nativeInstance;

  DocumentSnapshotFlutter(this.nativeInstance);

  @override
  DocumentData data() {
    return documentDataFromFlutterData(nativeInstance.data);
  }

  @override
  bool get exists => nativeInstance.exists;

  @override
  DocumentReference get ref => _wrapDocumentReference(nativeInstance.reference);
}

class QuerySnapshotFlutter implements QuerySnapshot {
  final native.QuerySnapshot nativeInstance;

  QuerySnapshotFlutter(this.nativeInstance);

  @override
  List<DocumentSnapshot> get docs => nativeInstance.documents
      ?.map((nativeInstance) => _wrapDocumentSnapshot(nativeInstance))
      ?.toList();

  @override
  List<DocumentChange> get documentChanges => nativeInstance.documentChanges
      ?.map((nativeInstance) => _wrapDocumentChange(nativeInstance))
      ?.toList();
}

class DocumentChangeFlutter implements DocumentChange {
  final native.DocumentChange nativeInstance;

  DocumentChangeFlutter(this.nativeInstance);

  @override
  DocumentSnapshot get document => null;

  @override
  int get newIndex => nativeInstance.newIndex;

  @override
  int get oldIndex => nativeInstance.oldIndex;

  @override
  DocumentChangeType get type => _wrapDocumentChangeType(nativeInstance.type);
}