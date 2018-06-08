@TestOn('vm')
library tekartik_firebase_sembast.firebase_io_src_test;

import 'package:test/test.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';
import 'package:tekartik_firebase_sembast/firebase_sembast.dart';
import 'package:tekartik_firebase_sembast/src/firestore_sembast.dart';

void main() {
  // init();
  //run(firebaseAdmin);
  var firebaseAdmin = firebaseSembast;
  var app = firebaseAdmin.initializeApp(name: 'test');
  var firestore = app.firestore();

  group('firestore_io', () {
    test('db_name', () async {
      var app = firebaseAdmin.initializeApp(name: 'test');
      var ioFirestore = app.firestore() as FirestoreSembast;
      expect(ioFirestore.dbPath, '.dart_tool/firebase_admin_shim/test.db');

      app = firebaseAdmin.initializeApp(name: 'test.db');
      ioFirestore = app.firestore() as FirestoreSembast;
      expect(ioFirestore.dbPath, '.dart_tool/firebase_admin_shim/test.db');

      app = firebaseAdmin.initializeApp(name: 'test/test.db');
      ioFirestore = app.firestore() as FirestoreSembast;
      expect(ioFirestore.dbPath, 'test/test.db');
    });

    group('DocumentData', () {
      test('dateTime', () {
        var date =
            new DateTime.fromMillisecondsSinceEpoch(12345657890123).toUtc();
        DocumentData documentData = new DocumentData();
        documentData.setDateTime('dateTime', date);
        expect(documentDataToRecordMap(documentData), {
          'dateTime': {r'$t': 'DateTime', r'$v': '2361-03-21T13:24:50.123Z'}
        });

        documentData = documentDataFromRecordMap(firestore, {
          'dateTime': {r'$t': 'DateTime', r'$v': '2361-03-21T13:24:50.123Z'}
        });
        // this is local time
        DateTime localDate = date.toLocal();
        expect(documentData.getDateTime('dateTime'), localDate);
      });

      test('sub data', () {
        DocumentDataMap documentData = new DocumentDataMap();
        DocumentData subData = new DocumentData();
        subData.setInt('test', 1234);
        documentData.setData('sub', subData);
        // store as a map
        expect(documentData.map['sub'], new isInstanceOf<Map>());
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
        DocumentDataMap documentData = new DocumentDataMap();
        DocumentData subData = new DocumentData();
        DocumentData subSubData = new DocumentData();
        subSubData.setInt('test', 1234);
        documentData.setData('sub', subData);
        subData.setData('subsub', subSubData);
        expect(documentData.map['sub'], new isInstanceOf<Map>());
        expect(documentDataToRecordMap(documentData), {
          'sub': {
            'subsub': {'test': 1234}
          }
        });
        expect(documentData.toMap(), {
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
        DocumentData documentData = new DocumentData();
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
        var documentData = new DocumentDataMap();
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
        var date = new DateTime.fromMillisecondsSinceEpoch(12345657890123);
        DocumentData documentData = new DocumentData();
        DocumentData subData = new DocumentData();
        DocumentData listItemDocumentData = new DocumentData();
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
