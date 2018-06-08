import 'dart:async';

import 'package:test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore_common.dart';

class FirestoreMock implements Firestore {
  @override
  CollectionReference collection(String path) => null;

  @override
  DocumentReference doc(String path) => new DocumentReferenceMock(path);

  @override
  WriteBatch batch() => null;

  @override
  Future runTransaction(Function(Transaction transaction) updateFunction) =>
      null;
}

class DocumentSnapshotMock implements DocumentSnapshot {
  @override
  final DocumentReferenceMock ref;

  DocumentSnapshotMock(this.ref);

  @override
  DocumentData data() => null;

  @override
  bool get exists => null;
}

class DocumentReferenceMock implements DocumentReference {
  DocumentReferenceMock(this.path);

  @override
  CollectionReference collection(String path) => null;

  @override
  Future delete() => null;

  @override
  Future<DocumentSnapshot> get() => null;

  @override
  String get id => url.basename(path);

  @override
  CollectionReference get parent => null;

  @override
  final String path;

  Future set(DocumentData documentData, [SetOptions options]) => null;

  @override
  Future update(DocumentData documentData) => null;

  @override
  Stream<DocumentSnapshot> onSnapshot() => null;
}

main() {
  group('path', () {
    test('sanitizeReferencePath', () {
      expect(sanitizeReferencePath(null), isNull);
      expect(sanitizeReferencePath('/test'), 'test');
      expect(sanitizeReferencePath('test/'), 'test');
      expect(sanitizeReferencePath('/test/'), 'test');
    });
    test('isDocumentReferencePath', () {
      expect(isDocumentReferencePath(null), isTrue);
      expect(isDocumentReferencePath('/test'), false);
      expect(isDocumentReferencePath('tests/doc'), isTrue);
      expect(isDocumentReferencePath('tests/doc/'), isTrue);
      expect(isDocumentReferencePath('tests/doc/coll/doc'), isTrue);
    });
  });
  group('queryInfo', () {
    test('queryInfoToJsonMap', () {
      var firestore = new FirestoreMock();
      var queryInfo = new QueryInfo();
      expect(queryInfoToJsonMap(queryInfo), {});

      queryInfo.limit = 1;
      queryInfo.offset = 2;
      queryInfo.orderBys = [
        new OrderByInfo()
          ..fieldPath = "field"
          ..ascending = true
      ];
      queryInfo.startAt(
          values: [new DateTime.fromMillisecondsSinceEpoch(1234567890123)]);
      queryInfo.endAt(
          snapshot: new DocumentSnapshotMock(
              new DocumentReferenceMock("path/to/dock")));
      queryInfo.addWhere(new WhereInfo("whereField",
          isLessThanOrEqualTo:
              new DateTime.fromMillisecondsSinceEpoch(12345678901234)));

      var expected = {
        'limit': 1,
        'offset': 2,
        'wheres': [
          {
            'fieldPath': 'whereField',
            'operator': '<=',
            'value': {r'$t': 'DateTime', r'$v': '2361-03-21T19:15:01.234Z'}
          }
        ],
        'orderBys': [
          {'fieldPath': 'field', 'direction': 'asc'}
        ],
        'startLimit': {
          'inclusive': true,
          'values': [
            {r'$t': 'DateTime', r'$v': '2009-02-13T23:31:30.123Z'}
          ]
        },
        'endLimit': {'inclusive': true, 'documentId': 'dock'}
      };
      expect(queryInfoToJsonMap(queryInfo), expected);

      // round trip
      expect(queryInfoToJsonMap(queryInfoFromJsonMap(firestore, expected)),
          expected);
    });
  });
}
