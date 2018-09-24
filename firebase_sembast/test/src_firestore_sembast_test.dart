@TestOn('vm')
library tekartik_firebase_sembast.firebase_io_src_test;

import 'package:path/path.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';
import 'package:tekartik_firebase_sembast/firebase_sembast_io.dart';
import 'package:tekartik_firebase_sembast/src/firestore_sembast.dart';
import 'package:test/test.dart';

void main() {
  var firebase = firebaseSembastIo;
  var app = firebase.initializeApp(name: 'test');
  var firestore = app.firestore();

  group('firestore_io', () {
    test('db_name', () async {
      var app = firebase.initializeApp(name: 'test');
      var ioFirestore = app.firestore() as FirestoreSembast;
      expect(ioFirestore.dbPath,
          join('.dart_tool', 'firebase_admin_shim', 'test.db'));

      app = firebase.initializeApp(name: 'test.db');
      ioFirestore = app.firestore() as FirestoreSembast;
      expect(ioFirestore.dbPath,
          join('.dart_tool', 'firebase_admin_shim', 'test.db'));

      app = firebase.initializeApp(name: join('test', 'test.db'));
      ioFirestore = app.firestore() as FirestoreSembast;
      expect(ioFirestore.dbPath, join('test', 'test.db'));
    });

    group('DocumentData', () {
      test('dateTime', () {
        var utcDate =
            DateTime.fromMillisecondsSinceEpoch(12345657890123).toUtc();
        var localDate = DateTime.fromMillisecondsSinceEpoch(123456578901234);
        DocumentData documentData = DocumentData();
        documentData.setDateTime('utcDateTime', utcDate);
        documentData.setDateTime('dateTime', localDate);
        expect(documentDataToRecordMap(documentData), {
          'utcDateTime': {r'$t': 'DateTime', r'$v': '2361-03-21T13:24:50.123Z'},
          'dateTime': {r'$t': 'DateTime', r'$v': '5882-03-08T14:08:21.234Z'}
        });

        documentData = documentDataFromRecordMap(
            firestore, documentDataToRecordMap(documentData));
        // this is local time
        expect(documentData.getDateTime('utcDateTime'), utcDate.toLocal());
        expect(documentData.getDateTime('dateTime'), localDate);
      });

      test('sub data', () {
        DocumentDataMap documentData = DocumentDataMap();
        DocumentData subData = DocumentData();
        subData.setInt('test', 1234);
        documentData.setData('sub', subData);
        // store as a map
        expect(documentData.map['sub'], const TypeMatcher<Map>());
        expect(documentDataToRecordMap(documentData), {
          'sub': {'test': 1234}
        });

        documentData = documentDataFromRecordMap(firestore, {
          'sub': {'test': 1234}
        });
        subData = documentData.getData('sub');
        expect(subData.getInt('test'), 1234);
      });

      test('sub data', () {
        DocumentDataMap documentData = DocumentDataMap();
        DocumentData subData = DocumentData();
        DocumentData subSubData = DocumentData();
        subSubData.setInt('test', 1234);
        documentData.setData('sub', subData);
        subData.setData('subsub', subSubData);
        expect(documentData.map['sub'], const TypeMatcher<Map>());
        expect(documentDataToRecordMap(documentData), {
          'sub': {
            'subsub': {'test': 1234}
          }
        });
        expect(documentData.asMap(), {
          'sub': {
            'subsub': {'test': 1234}
          }
        });

        documentData = documentDataFromRecordMap(firestore, {
          'sub': {
            'subsub': {'test': 1234}
          }
        });
        subData = documentData.getData('sub');
        subSubData = subData.getData('subsub');
        expect(subSubData.getInt('test'), 1234);
      });

      test('list', () {
        DocumentData documentData = DocumentData();
        documentData.setList('test', [1, 2]);
        expect(documentDataToRecordMap(documentData), {
          'test': [1, 2]
        });

        documentData = documentDataFromRecordMap(firestore, {
          'test': [1, 2]
        });
        expect(documentData.getList('test'), [1, 2]);
      });

      test('documentMapFromRecordMap', () {
        var documentData = DocumentDataMap();
        expect(documentData.map, {});
        documentDataFromRecordMap(firestore, {}, documentData);
        expect(documentData.map, {});
        documentDataFromRecordMap(firestore, null, documentData);
        expect(documentData.map, {});

        // basic types
        documentDataFromRecordMap(
            firestore,
            {'int': 1234, 'bool': true, 'string': 'text', 'double': 1.5},
            documentData);
        expect(documentData.map,
            {'int': 1234, 'bool': true, 'string': 'text', 'double': 1.5});

        // date time
        documentDataFromRecordMap(
            firestore,
            {'dateTime': 1234, 'bool': true, 'string': 'text', 'double': 1.5},
            documentData);
      });

      test('complex', () {
        var date = DateTime.fromMillisecondsSinceEpoch(12345657890123);
        DocumentData documentData = DocumentData();
        DocumentData subData = DocumentData();
        DocumentData listItemDocumentData = DocumentData();
        listItemDocumentData.setDateTime('date', date);
        listItemDocumentData.setInt('test', 12345);
        documentData.setData('sub', subData);
        subData.setList('list', [1234, date, listItemDocumentData]);
        subData.setData('map', listItemDocumentData);

        var expected = {
          'sub': {
            'list': [
              1234,
              {r'$t': 'DateTime', r'$v': '2361-03-21T13:24:50.123Z'},
              {
                'date': {r'$t': 'DateTime', r'$v': '2361-03-21T13:24:50.123Z'},
                'test': 12345
              }
            ],
            'map': {
              'date': {r'$t': 'DateTime', r'$v': '2361-03-21T13:24:50.123Z'},
              'test': 12345
            }
          }
        };
        expect(documentDataToRecordMap(documentData), expected);
        documentData = documentDataFromRecordMap(firestore, expected);
        expect(documentDataToRecordMap(documentData), expected);
      });
    });
  });
}
