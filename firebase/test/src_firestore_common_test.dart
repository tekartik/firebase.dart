import 'dart:async';

import 'package:tekartik_firebase/src/firestore.dart';
import 'package:tekartik_firebase/utils/firestore_mixin.dart';
import 'package:test/test.dart';
import 'package:path/path.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore_common.dart';

class FirestoreMock extends Object with FirestoreMixin implements Firestore {
  @override
  CollectionReference collection(String path) => null;

  @override
  DocumentReference doc(String path) => DocumentReferenceMock(path);

  @override
  WriteBatch batch() => null;

  @override
  Future runTransaction(Function(Transaction transaction) updateFunction) =>
      null;

  @override
  void settings(FirestoreSettings settings) {}
}

class DocumentSnapshotMock implements DocumentSnapshot {
  @override
  final DocumentReferenceMock ref;

  DocumentSnapshotMock(this.ref);

  @override
  Map<String, dynamic> get data => null;

  @override
  bool get exists => null;

  @override
  Timestamp get updateTime => null;

  @override
  Timestamp get createTime => null;
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

  Future set(Map<String, dynamic> data, [SetOptions options]) => null;

  @override
  Future update(Map<String, dynamic> data) => null;

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
      var firestore = FirestoreMock();
      var queryInfo = QueryInfo();
      expect(queryInfoToJsonMap(queryInfo), {});

      queryInfo.limit = 1;
      queryInfo.offset = 2;
      queryInfo.orderBys = [
        OrderByInfo()
          ..fieldPath = "field"
          ..ascending = true
      ];
      queryInfo.startAt(
          values: [DateTime.fromMillisecondsSinceEpoch(1234567890123)]);
      queryInfo.endAt(
          snapshot:
              DocumentSnapshotMock(DocumentReferenceMock("path/to/dock")));
      queryInfo.addWhere(WhereInfo("whereField",
          isLessThanOrEqualTo:
              DateTime.fromMillisecondsSinceEpoch(12345678901234)));

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
