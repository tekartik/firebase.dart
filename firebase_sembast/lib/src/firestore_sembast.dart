import 'dart:async';

import 'package:path/path.dart';
import 'package:sembast/sembast.dart' hide Transaction;
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_memory.dart' as sembast;
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';
import 'package:tekartik_firebase/src/firestore_common.dart';
import 'package:tekartik_firebase_sembast/src/firebase_sembast.dart' as sembast;
import 'package:uuid/uuid.dart';

const revKey = r'$rev';

Map<String, dynamic> dateTimeToRecordValue(DateTime dateTime) =>
    dateTimeToJsonValue(dateTime);

Map<String, dynamic> documentReferenceToRecordValue(
        DocumentReferenceSembast documentReference) =>
    documentReferenceToJsonValue(documentReference);

DateTime recordValueToDateTime(Map map) => jsonValueToDateTime(map)?.toLocal();

DocumentReference recordValueToDocumentReference(
        Firestore firestore, Map map) =>
    jsonValueToDocumentReference(firestore, map);

// TODO handle sub field name
Map<String, dynamic> toSelectedMap(Map map, List<String> fields) {
  var selectedMap = <String, dynamic>{};
  for (var key in fields) {
    if (map.containsKey(key)) {
      selectedMap[key] = map[key];
    }
  }
  return selectedMap;
}

dynamic recordValueToValue(Firestore firestore, dynamic recordValue) {
  if (recordValue == null ||
      recordValue is num ||
      recordValue is bool ||
      recordValue is String) {
    return recordValue;
  } else if (recordValue is Map) {
    if (recordValue.containsKey(jsonTypeField)) {
      return jsonToDocumentDataValue(firestore, recordValue);
    } else {
      return recordValue
          .map((key, recordValue) =>
              new MapEntry(key, recordValueToValue(firestore, recordValue)))
          .cast<String, dynamic>();
    }
  } else if (recordValue is Iterable) {
    return recordValue
        .map((recordValue) => recordValueToValue(firestore, recordValue))
        .toList();
  }
  throw 'recordValueToValue not supported $recordValue ${recordValue
      .runtimeType}';
}

dynamic valueToRecordValue(dynamic value) {
  if (value == null || value is num || value is bool || value is String) {
    return value;
  } else if (value == FieldValue.serverTimestamp) {
    return dateTimeToRecordValue(new DateTime.now());
  } else if (value is DateTime) {
    return dateTimeToRecordValue(value);
  } else if (value is Map) {
    return value
        .map((key, value) => new MapEntry(key, valueToRecordValue(value)));
  } else if (value is List) {
    return value.map((subValue) => valueToRecordValue(subValue)).toList();
  } else if (value is DocumentDataMap) {
    // this happens when it is a list item
    return value.map
        .map((key, value) => new MapEntry(key, valueToRecordValue(value)));
  } else if (value is DocumentReferenceSembast) {
    return documentReferenceToRecordValue(value);
  } else if (value is Blob) {
    return blobToJsonValue(value);
  } else if (value is GeoPoint) {
    return geoPointToJsonValue(value);
  }
  throw 'not supported $value ${value.runtimeType}';
}

DocumentDataMap _documentDataMap(DocumentData documentData) =>
    documentData as DocumentDataMap;

int recordMapRev(Map<String, dynamic> recordMap) =>
    recordMap != null ? recordMap[revKey] as int : null;

DocumentSnapshotSembast documentSnapshotFromRecordMap(
    FirestoreSembast firestore, String path, Map<String, dynamic> recordMap) {
  return new DocumentSnapshotSembast(
      new DocumentReferenceSembast(
          new ReferenceContextSembast(firestore, path)),
      recordMapRev(recordMap),
      documentDataFromRecordMap(firestore, recordMap));
}

// merge with existing record map if any
Map<String, dynamic> documentDataToRecordMap(DocumentData documentData,
    [Map<String, dynamic> recordMap]) {
  if (documentData == null && recordMap == null) {
    return null;
  }
  recordMap = recordMap != null
      ? new Map<String, dynamic>.from(recordMap)
      : <String, dynamic>{};
  if (documentData == null) {
    return recordMap;
  }
  _documentDataMap(documentData).map.forEach((String key, value) {
    // special delete field
    if (value == FieldValue.delete) {
      // remove
      recordMap.remove(key);
    } else {
      recordMap[key] = valueToRecordValue(value);
    }
  });
  return recordMap;
}

DocumentDataMap documentDataFromRecordMap(
    Firestore firestore, Map<String, dynamic> recordMap,
    [DocumentData documentData]) {
  if (documentData == null && recordMap == null) {
    return null;
  }
  documentData ??= new DocumentData();
  if (recordMap != null) {
    recordMap.forEach((String key, value) {
      // ignore rev
      if (key == revKey) {
        return;
      }
      // call setValue to prevent checking type again
      (documentData as DocumentDataMap)
          .setValue(key, recordValueToValue(firestore, value));
    });
  }
  return documentData as DocumentDataMap;
}

bool mapWhere(DocumentData documentData, WhereInfo where) {
  var fieldValue =
      _documentDataMap(documentData).valueAtFieldPath(where.fieldPath);
  if (where.isNull == true) {
    return fieldValue == null;
  } else if (where.isNull == false) {
    return fieldValue != null;
  } else if (where.isEqualTo != null) {
    return fieldValue == where.isEqualTo;
  } else if (where.isGreaterThan != null) {
    // ignore: non_bool_operand
    return (fieldValue == null) || (fieldValue > where.isGreaterThan);
  } else if (where.isGreaterThanOrEqualTo != null) {
    // ignore: non_bool_operand
    return fieldValue == null || fieldValue >= where.isGreaterThanOrEqualTo;
  } else if (where.isLessThan != null) {
    // ignore: non_bool_operand
    return fieldValue != null && fieldValue < where.isLessThan;
  } else if (where.isLessThanOrEqualTo != null) {
    // ignore: non_bool_operand
    return fieldValue != null && fieldValue <= where.isLessThanOrEqualTo;
  }
  return false;
}

// new format
int firestoreSembastDatabaseVersion = 1;

class CollectionSubscription
    extends FirestoreSubscription<DocumentChangeSembast> {}

class DocumentSubscription
    extends FirestoreSubscription<DocumentSnapshotSembast> {}

abstract class FirestoreSubscription<T> {
  String path;
  int count = 0;
  var streamController = new StreamController<T>.broadcast();
}

const String docStoreName = 'doc';

class WriteResultSembast {
  final String path;

  WriteResultSembast(this.path);

  bool get added =>
      previousSnapshot?.exists != true && newSnashot?.exists == true;

  bool get removed =>
      previousSnapshot?.exists == true && newSnashot?.exists != true;

  bool get exists => newSnashot?.exists == true;

  DocumentSnapshotSembast previousSnapshot;
  DocumentSnapshotSembast newSnashot;
}

class FirestoreSembast implements Firestore {
  var dbLock = new Lock();
  Database db;
  final sembast.AppSembast app;

  FirestoreSembast(this.app);

  Future close() async {
    for (var subscription in subscriptions.values.toList()) {
      await _clearSubscription(subscription);
    }
  }

  String get dbPath {
    String name = app.name == "[DEFAULT]" ? "default" : app.name;

    // path?
    if (split(name).length == 1) {
      name = join(app.localPath, name);
    }
    // add extension
    if (extension(name).isEmpty) {
      name = "$name.db";
    }
    return name;
  }

  @override
  CollectionReference collection(String path) {
    return new CollectionReferenceSembast(_context(this, path));
  }

  @override
  DocumentReference doc(String path) {
    return new DocumentReferenceSembast(_context(this, path));
  }

  Future<Database> get ready async {
    if (db != null) {
      return db;
    }
    return await dbLock.synchronized(() async {
      if (db == null) {
        // If it is a name (no path, no extension) use it as id

        String name = dbPath;
        print('opening database ${name}');
        var db = await app.firebase.databaseFactory
            .openDatabase(name, version: firestoreSembastDatabaseVersion,
                onVersionChanged: (db, oldVersion, newVersion) async {
          if (oldVersion == null) {
            // creating ok
          } else {
            if (newVersion < firestoreSembastDatabaseVersion) {
              // clear store
              await db.findStore(docStoreName)?.clear();
            }
          }
        });
        this.db = db;
        return db;
      } else {
        return db;
      }
    });
  }

  // key is path
  final subscriptions = <String, FirestoreSubscription>{};

  FirestoreSubscription<T> findSubscription<T>(String path) {
    return subscriptions[path] as FirestoreSubscription<T>;
  }

  CollectionSubscription addCollectionSubscription(String path) {
    return _addSubscription(path, () => new CollectionSubscription())
        as CollectionSubscription;
  }

  DocumentSubscription addDocumentSubscription(String path) {
    return _addSubscription(path, () => new DocumentSubscription())
        as DocumentSubscription;
  }

  FirestoreSubscription<T> _addSubscription<T>(
      String path, FirestoreSubscription<T> create()) {
    var subscription = findSubscription<T>(path);
    if (subscription == null) {
      subscription = create()..path = path;
      subscriptions[path] = subscription;
    }
    subscription.count++;
    return subscription;
  }

  // ref counting
  Future removeSubscription(FirestoreSubscription subscription) async {
    if (--subscription.count == 0) {
      await _clearSubscription(subscription);
    }
  }

  Future _clearSubscription(FirestoreSubscription subscription) async {
    subscriptions.remove(subscription.path);
    await subscription.streamController.close();
  }

  Future<Map<String, dynamic>> txnGetRecordMap(
      sembast.Transaction txn, String path) async {
    Map<String, dynamic> recordMap =
        await txn.getStore(docStoreName).get(path) as Map<String, dynamic>;
    return recordMap;
  }

  Future<DocumentSnapshotSembast> txnGetDocumentSnapshot(
      sembast.Transaction txn, String path) async {
    Map<String, dynamic> recordMap = await txnGetRecordMap(txn, path);
    return documentFromRecordMap(path, recordMap);
  }

  DocumentSnapshotSembast documentFromRecordMap(
      String path, Map<String, dynamic> recordMap) {
    int rev;
    if (recordMap != null) {
      rev = recordMap[r'$rev'] as int;
      recordMap.remove(r'$rev');
    }
    return new DocumentSnapshotSembast(
        new DocumentReferenceSembast(new ReferenceContextSembast(this, path)),
        rev,
        documentDataFromRecordMap(this, recordMap));
  }

  // return previous data
  Future<WriteResultSembast> txnDelete(
      sembast.Transaction txn, String path) async {
    var result = new WriteResultSembast(path);
    var docStore = txn.getStore(docStoreName);
    result.previousSnapshot = await txnGetDocumentSnapshot(txn, path);
    await docStore.delete(path);
    return result;
  }

  Future<WriteResultSembast> txnSet(
      sembast.Transaction txn, String path, DocumentData documentData,
      [SetOptions options]) async {
    var result = new WriteResultSembast(path);
    var docStore = txn.getStore(docStoreName);
    var existingRecordMap = await txnGetRecordMap(txn, path);
    result.previousSnapshot = documentFromRecordMap(path, existingRecordMap);
    Map<String, dynamic> recordMap;

    // Update rev
    int rev = (result.previousSnapshot?.rev ?? 0) + 1;
    // merging?
    if (options?.merge == true) {
      recordMap = documentDataToRecordMap(documentData, existingRecordMap);
    } else {
      recordMap = documentDataToRecordMap(documentData);
    }

    rev++;
    if (recordMap != null) {
      recordMap[revKey] = rev;
    }

    result.newSnashot = documentSnapshotFromRecordMap(this, path, recordMap);
    Record record = new Record(docStore.store, recordMap, path);
    await txn.putRecord(record);
    return result;
  }

  /*
  setDocumentData(Transaction txn, String path, DocumentData documentData,
      [SetOptions options]) async {
    WriteResultIo result = await txnSet(txn, path, documentData, options);
    notify(result);
  }
  */

  void notify(WriteResultSembast result) {
    var path = result.path;
    var documentSubscription = findSubscription(path);
    if (documentSubscription != null) {
      documentSubscription.streamController.add(new DocumentSnapshotSembast(
          new DocumentReferenceSembast(new ReferenceContextSembast(this, path)),
          result.newSnashot?.rev,
          result.newSnashot?.documentData));
    }
    // notify collection listeners
    var collectionSubscription = findSubscription(url.dirname(path));
    if (collectionSubscription != null) {
      collectionSubscription.streamController.add(new DocumentChangeSembast(
          result.added
              ? DocumentChangeType.added
              : (result.removed
                  ? DocumentChangeType.removed
                  : DocumentChangeType.modified),
          new DocumentSnapshotSembast.fromSnapshot(
              result.removed ? result.previousSnapshot : result.newSnashot,
              true),
          null,
          null));
    }
  }

  @override
  WriteBatch batch() => new WriteBatchSembast(this);

  @override
  Future runTransaction(
      Function(Transaction transaction) updateFunction) async {
    var db = await ready;
    var transaction = new TransactionSembast(this);
    List<WriteResultSembast> results = await db.transaction((txn) async {
      // Initialize the transaction
      transaction.nativeTransaction = txn;

      await updateFunction(transaction);
      return await transaction.txnCommit(txn);
    });
    transaction.notify(results);
  }
}

class WriteBatchSembast extends WriteBatchBase implements WriteBatch {
  final FirestoreSembast firestore;

  WriteBatchSembast(this.firestore);

  Future<List<WriteResultSembast>> txnCommit(sembast.Transaction txn) async {
    List<WriteResultSembast> results = [];
    for (var operation in operations) {
      if (operation is WriteBatchOperationDelete) {
        results.add(await firestore.txnDelete(txn, operation.docRef.path));
      } else if (operation is WriteBatchOperationSet) {
        results.add(await firestore.txnSet(txn, operation.docRef.path,
            operation.documentData, operation.options));
      } else if (operation is WriteBatchOperationUpdate) {
        var path = operation.docRef.path;
        var record = await txn.getStore(docStoreName).getRecord(path);
        if (record == null) {
          throw new Exception("update failed, record $path does not exit");
        }
        results.add(await firestore.txnSet(
            txn, path, operation.documentData, new SetOptions(merge: true)));
      } else {
        throw 'not supported $operation';
      }
    }
    return results;
  }

  @override
  Future commit() async {
    var db = await firestore.ready;

    List<WriteResultSembast> results = await db.transaction((txn) async {
      return txnCommit(txn);
    });

    notify(results);
  }

  // To use after txtCommit
  void notify(List<WriteResultSembast> results) {
    for (var result in results) {
      firestore.notify(result);
    }
  }
}

// It is basically a batch with gets before in a transaction
class TransactionSembast extends WriteBatchSembast implements Transaction {
  var completer = new Completer();
  sembast.Transaction nativeTransaction;

  TransactionSembast(FirestoreSembast firestore) : super(firestore);

  @override
  Future<DocumentSnapshot> get(DocumentReference documentRef) async {
    var snapshot = await firestore.txnGetDocumentSnapshot(
        nativeTransaction, _wrapDocumentReference(documentRef).path);
    return snapshot;
  }
}

class BaseReferenceSembast extends Object with AttributesMixin {
  final ReferenceContextSembast context;

  BaseReferenceSembast(this.context);

  ReferenceContextSembast pathContext(String path) =>
      new ReferenceContextSembast(context.firestore, path);
}

class DocumentSnapshotSembast implements DocumentSnapshot {
  final DocumentReferenceSembast documentReference;
  final int rev;
  final DocumentDataMap documentData;

  bool _exists;

  @override
  bool get exists => _exists;

  DocumentSnapshotSembast(this.documentReference, this.rev, this.documentData,
      [bool exists]) {
    _exists = exists ??= documentData != null;
  }

  DocumentSnapshotSembast.fromSnapshot(
      DocumentSnapshotSembast snapshot, bool exists)
      : this(snapshot.documentReference, snapshot.rev, snapshot.documentData,
            exists);

  @override
  Map<String, dynamic> get data => documentData?.asMap();

  @override
  DocumentReference get ref => documentReference;
}

ReferenceContextSembast _context(FirestoreSembast firestore, String path) =>
    new ReferenceContextSembast(firestore, path);

class DocumentReferenceSembast extends BaseReferenceSembast
    with AttributesMixin
    implements DocumentReference {
  DocumentReferenceSembast(ReferenceContextSembast context) : super(context);

  @override
  CollectionReference collection(String path) =>
      new CollectionReferenceSembast(pathContext(getChildPath(path)));

  @override
  Future delete() async {
    WriteResultSembast result;
    var db = await firestore.ready;
    await db.transaction((txn) async {
      result = await firestore.txnDelete(txn, path);
    });
    if (result != null) {
      firestore.notify(result);
    }
  }

  @override
  Future<DocumentSnapshot> get() async {
    var db = await firestore.ready;
    Map<String, dynamic> recordMap =
        await db.getStore(docStoreName).get(path) as Map<String, dynamic>;
    // always create a snapshot even if it doest not exist
    return documentSnapshotFromRecordMap(firestore, path, recordMap);
  }

  @override
  Future set(Map<String, dynamic> data, [SetOptions options]) async {
    WriteResultSembast result;
    var db = await firestore.ready;
    await db.transaction((txn) async {
      result =
          await firestore.txnSet(txn, path, new DocumentData(data), options);
    });
    if (result != null) {
      firestore.notify(result);
    }
  }

  String get _key => path;

  @override
  Future update(Map<String, dynamic> data) async {
    WriteResultSembast result;

    var db = await firestore.ready;
    await db.transaction((txn) async {
      var record = await txn.getStore(docStoreName).getRecord(_key);
      if (record == null) {
        throw new Exception("update failed, record $path does not exit");
      }
      result = await firestore.txnSet(
          txn, path, new DocumentData(data), new SetOptions(merge: true));
    });
    if (result != null) {
      firestore.notify(result);
    }
  }

  @override
  CollectionReference get parent {
    String parentPath = this.parentPath;
    if (parentPath == null) {
      return null;
    } else {
      return new CollectionReferenceSembast(pathContext(parentPath));
    }
  }

  @override
  Stream<DocumentSnapshot> onSnapshot() {
    var subscription = firestore.addDocumentSubscription(path);
    var querySubscription;
    var controller =
        new StreamController<DocumentSnapshotSembast>(onCancel: () {
      querySubscription.cancel();
    });

    querySubscription = subscription.streamController.stream.listen(
        (DocumentSnapshotSembast snapshot) async {
      controller.add(snapshot);
    }, onDone: () {
      firestore.removeSubscription(subscription);
    });

    // Get the first batch
    get().then((DocumentSnapshot snapshot) {
      var snapshotSembast = _wrapDocumentSnapshot(snapshot);
      controller.add(snapshotSembast);
    });
    return controller.stream;
  }
}

class CollectionReferenceSembast extends BaseReferenceSembast
    with QueryMixin, AttributesMixin
    implements CollectionReference {
  CollectionReferenceSembast(ReferenceContextSembast context) : super(context);

  // always created initially
  QueryInfo queryInfo = new QueryInfo();

  @override
  DocumentReference doc([String path]) {
    path ??= _generateId();
    return new DocumentReferenceSembast(pathContext(getChildPath(path)));
  }

  String _generateId() => new Uuid().v4().toString();

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    String id = _generateId();
    String path = url.join(this.path, id);

    WriteResultSembast result;

    var db = await firestore.ready;
    await db.transaction((txn) async {
      result = await firestore.txnSet(txn, path, new DocumentData(data));
    });
    if (result != null) {
      firestore.notify(result);
    }

    DocumentReferenceSembast documentReference =
        new DocumentReferenceSembast(pathContext(path));
    return documentReference;
  }

  @override
  DocumentReference get parent {
    String parentPath = this.parentPath;
    if (parentPath == null) {
      return null;
    } else {
      return new DocumentReferenceSembast(pathContext(parentPath));
    }
  }
}

class ReferenceContextSembast {
  final FirestoreSembast firestore;
  final String path;

  ReferenceContextSembast(this.firestore, this.path);
}

class QuerySembast extends Object
    with QueryMixin, AttributesMixin
    implements Query {
  final ReferenceContextSembast context;

  QuerySembast(this.context);

  QueryInfo queryInfo;
}

T safeGetItem<T>(List<T> list, int index) {
  if (list != null && list.length > index) {
    return list[index];
  }
  return null;
}

bool mapQueryInfo(DocumentDataMap documentData, QueryInfo queryInfo) {
  //var data = documentData.map;
  // if (data != null) {
  //bool add = true;

  if (queryInfo.wheres.isNotEmpty) {
    for (var where in queryInfo.wheres) {
      if (!mapWhere(documentData, where)) {
        return false;
      }
    }
  }

  if (((queryInfo.startLimit?.values != null ||
              queryInfo.endLimit?.values != null) &&
          queryInfo.orderBys.isNotEmpty) ||
      queryInfo.wheres.isNotEmpty) {
    for (int i = 0; i < queryInfo.orderBys.length; i++) {
      dynamic value =
          documentData.valueAtFieldPath(queryInfo.orderBys[i].fieldPath);

      if (queryInfo.startLimit?.inclusive == true) {
        dynamic startAt = safeGetItem(queryInfo.startLimit?.values, i);
        if (startAt != null) {
          // ignore: non_bool_operand
          if (value == null || value < startAt) {
            return false;
          }
        }
      } else {
        dynamic startAfter = safeGetItem(queryInfo.startLimit?.values, i);
        if (startAfter != null) {
          // ignore: non_bool_operand
          if (value == null || value <= startAfter) {
            return false;
          }
        }
      }

      if (queryInfo.endLimit?.inclusive == true) {
        dynamic endAt = safeGetItem(queryInfo.endLimit?.values, i);
        if (endAt != null) {
          // ignore: non_bool_operand
          if (value == null || value > endAt) {
            return false;
          }
        }
      } else {
        dynamic endBefore = safeGetItem(queryInfo.endLimit?.values, i);
        if (endBefore != null) {
          // ignore: non_bool_operand
          if (value == null || value >= endBefore) {
            return false;
          }
        }
      }
    }
  }
  return true;
}

abstract class QueryMixin implements Query, AttributesMixin {
  ReferenceContextSembast get context;

  QueryInfo get queryInfo;

  ReferenceContextSembast pathContext(String path);

  @override
  Future<QuerySnapshot> get() async {
    var db = await firestore.ready;

    // Get and filter
    List<DocumentSnapshotSembast> docs = [];
    for (Record record
        in await db.getStore(docStoreName).findRecords(new Finder())) {
      String recordPath = record.key;
      String parentPath = url.dirname(recordPath);
      if (parentPath == path) {
        var docRef =
            new DocumentReferenceSembast(pathContext(record.key as String));
        var documentData = documentDataFromRecordMap(
            firestore, record.value as Map<String, dynamic>);

        if (mapQueryInfo(documentData, queryInfo)) {
          docs.add(documentSnapshotFromRecordMap(
              firestore, docRef.path, record.value as Map<String, dynamic>));
        }
      }
    }

    // order
    if (queryInfo.orderBys.isNotEmpty) {
      docs.sort((DocumentSnapshotSembast snapshot1,
          DocumentSnapshotSembast snapshot2) {
        int cmp = 0;
        for (var orderBy in queryInfo.orderBys) {
          String keyPath = orderBy.fieldPath;
          bool ascending = orderBy.ascending;

          int _rawCompare(Comparable object1, Comparable object2) {
            if (object2 == null) {
              if (object1 == null) {
                return 0;
              }
              return -1;
              // put object2 at the end
            } else if (object1 == null) {
              // put object1 at the end
              return 1;
            }
            return object1.compareTo(object2);
          }

          int _compare(Comparable object1, Comparable object2) {
            int rawCompare = _rawCompare(object1, object2);
            if (ascending) {
              return rawCompare;
            } else {
              return -rawCompare;
            }
          }

          cmp = _compare(
              snapshot1.documentData.valueAtFieldPath(keyPath) as Comparable,
              snapshot2.documentData.valueAtFieldPath(keyPath) as Comparable);
          if (cmp != 0) {
            break;
          }
        }
        return cmp;
      });
    }

    // Handle snapshot filtering (after ordering)
    List<DocumentSnapshotSembast> filteredDocs = [];
    if (queryInfo.startLimit?.documentId != null ||
        queryInfo.endLimit?.documentId != null) {
      bool add = true;
      if (queryInfo.startLimit?.documentId != null) {
        add = false;
      }
      for (var snapshot in docs) {
        if (!add && queryInfo.startLimit?.documentId != null) {
          if (snapshot.ref.id == queryInfo.startLimit.documentId) {
            add = true;
            if (!queryInfo.startLimit.inclusive) {
              // skip this one
              continue;
            }
          }
        }
        // stop now?
        if (add && queryInfo.endLimit?.documentId != null) {
          if (snapshot.ref.id == queryInfo.endLimit.documentId) {
            if (queryInfo.endLimit.inclusive) {
              filteredDocs.add(snapshot);
            }
            break;
          }
        }

        if (add) {
          filteredDocs.add(snapshot);
        }
      }

      docs = filteredDocs;
    }

    // offset && limit
    if (queryInfo.limit != null || queryInfo.offset != null) {
      List<DocumentSnapshotSembast> limitedDocs = [];
      int index = 0;
      for (var snapshot in docs) {
        if (queryInfo.offset != null) {
          if (index < queryInfo.offset) {
            index++;
            continue;
          }
        }
        if (queryInfo.limit != null) {
          if (limitedDocs.length >= queryInfo.limit) {
            break;
          }
        }
        index++;
        limitedDocs.add(snapshot);
      }
      docs = limitedDocs;
    }

    // Apply select
    if (queryInfo?.selectKeyPaths != null) {
      List<DocumentSnapshotSembast> selectedDocs = [];
      for (var snapshot in docs) {
        var data = snapshot.documentData.map;
        selectedDocs.add(new DocumentSnapshotSembast(
            _wrapDocumentReference(snapshot.ref),
            snapshot.rev,
            documentDataFromRecordMap(
                firestore, toSelectedMap(data, queryInfo.selectKeyPaths)),
            true));
      }
      docs = selectedDocs;
    }
    return new QuerySnapshotSembast(docs, <DocumentChangeSembast>[]);
  }

  @override
  Query select(List<String> list) {
    return clone()..queryInfo.selectKeyPaths = list;
  }

  @override
  Query limit(int limit) => clone()..queryInfo.limit = limit;

  @override
  Query orderBy(String key, {bool descending}) => clone()
    ..addOrderBy(
        key, descending == true ? orderByDescending : orderByAscending);

  QuerySembast clone() {
    return new QuerySembast(context)..queryInfo = queryInfo?.clone();
  }

  @override
  Query where(
    String fieldPath, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  }) =>
      clone()
        ..queryInfo.addWhere(new WhereInfo(fieldPath,
            isEqualTo: isEqualTo,
            isLessThan: isLessThan,
            isLessThanOrEqualTo: isGreaterThanOrEqualTo,
            isGreaterThan: isGreaterThan,
            isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            isNull: isNull));

  addOrderBy(String key, String directionStr) {
    var orderBy = new OrderByInfo()
      ..fieldPath = key
      ..ascending = directionStr != orderByDescending;
    queryInfo.orderBys.add(orderBy);
  }

  @override
  Query startAt({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.startAt(snapshot: snapshot, values: values);

  @override
  Query startAfter({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.startAfter(snapshot: snapshot, values: values);

  @override
  Query endAt({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.endAt(snapshot: snapshot, values: values);

  @override
  Query endBefore({DocumentSnapshot snapshot, List values}) =>
      clone()..queryInfo.endBefore(snapshot: snapshot, values: values);

  @override
  Stream<QuerySnapshot> onSnapshot() {
    var collectionSubscription = firestore.addCollectionSubscription(path);
    var querySubscription;
    var controller = new StreamController<QuerySnapshotSembast>(onCancel: () {
      querySubscription.cancel();
    });

    querySubscription = collectionSubscription.streamController.stream.listen(
        (DocumentChangeSembast documentChange) async {
      // get the base data
      var querySnapshot = await get() as QuerySnapshotSembast;
      if (mapQueryInfo(documentChange.document.documentData, queryInfo)) {
        if (documentChange.type == null) {
          if (querySnapshot.contains(documentChange.document)) {
            documentChange.type = DocumentChangeType.modified;
          } else {
            documentChange.type = DocumentChangeType.added;
          }
        }
        querySnapshot.documentChanges.add(documentChange);
      } else if (documentChange.type == DocumentChangeType.removed) {
        if (querySnapshot.contains(documentChange.document)) {
          querySnapshot.documentChanges.add(documentChange);
        }
      }
      controller.add(querySnapshot);
    }, onDone: () {
      firestore.removeSubscription(collectionSubscription);
    });

    // Get the first batch
    get().then((QuerySnapshot querySnaphost) {
      var querySnapshotIo = querySnaphost as QuerySnapshotSembast;
      // set index
      int index = 0;
      for (var doc in querySnaphost.docs) {
        querySnapshotIo.documentChanges.add(new DocumentChangeSembast(
            DocumentChangeType.added, _wrapDocumentSnapshot(doc), index++, -1));
      }
      controller.add(querySnapshotIo);
    });
    return controller.stream;
  }
}

abstract class ReferenceAttributes {
  ReferenceContextSembast get context;

  String get parentPath;

  String get id;

  String getChildPath(String path);
}

abstract class AttributesMixin implements ReferenceAttributes {
  ReferenceContextSembast get context;

  FirestoreSembast get firestore => context.firestore;

  String get path => context.path;

  @override
  String get parentPath {
    String dirPath = url.dirname(path);
    if (dirPath?.length == 0) {
      return null;
    } else if (dirPath == ".") {
      // Mimic firestore behavior where the top document has a "" path
      return '';
    } else if (dirPath == "/") {
      // Mimic firestore behavior where the top document has a "" path
      return '';
    }
    return dirPath;
  }

  @override
  String get id => url.basename(path);

  @override
  String getChildPath(String path) => url.join(this.path, path);

  ReferenceContextSembast pathContext(String path) =>
      new ReferenceContextSembast(firestore, path);
}

class DocumentChangeSembast implements DocumentChange {
  DocumentChangeSembast(this.type, this.document, this.newIndex, this.oldIndex);

  DocumentChangeType type;

  @override
  final DocumentSnapshotSembast document;

  @override
  final int newIndex;

  @override
  final int oldIndex;
}

class QuerySnapshotSembast implements QuerySnapshot {
  QuerySnapshotSembast(this.docs, this.documentChanges);

  @override
  final List<DocumentSnapshotSembast> docs;

  @override
  final List<DocumentChange> documentChanges;

  bool contains(DocumentSnapshotSembast document) {
    for (var doc in docs) {
      if (doc.ref.path == document.ref.path) {
        return true;
      }
    }
    return false;
  }
}

DocumentSnapshotSembast _wrapDocumentSnapshot(DocumentSnapshot snapshot) =>
    snapshot as DocumentSnapshotSembast;

DocumentReferenceSembast _wrapDocumentReference(DocumentReference ref) =>
    ref as DocumentReferenceSembast;
