import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_firebase/src/firestore.dart';
import 'package:tekartik_firebase/src/firestore_common.dart';

import 'src_firestore_common_test.dart';

main() {
  var firestore = new FirestoreMock();
  group('jsonMap', () {
    test('dateTime', () {
      expect(
          dateTimeToJsonValue(
              new DateTime.fromMillisecondsSinceEpoch(123456578901234)),
          {r'$t': 'DateTime', r'$v': '5882-03-08T14:08:21.234Z'});

      expect(
          jsonValueToDateTime(
              {r'$t': 'DateTime', r'$v': '5882-03-08T14:08:21.234Z'}),
          new DateTime.fromMillisecondsSinceEpoch(123456578901234).toUtc());
    });

    test('fieldValue', () {
      expect(fieldValueToJsonValue(FieldValue.delete),
          {r'$t': 'FieldValue', r'$v': '~delete'});
      expect(fieldValueToJsonValue(FieldValue.serverTimestamp),
          {r'$t': 'FieldValue', r'$v': '~serverTimestamp'});
    });

    test('list', () {
      var data = new DocumentData();
      expect(data.getList('list'), isNull);
      data.setList('list', <dynamic>[1, 3]);
      List<int> list = data.getList('list');
      expect(list, [1, 3]);
    });

    test('blob', () {
      var data = new DocumentData();
      data.setBlob("blob", new Blob(null));
      expect(documentDataToJsonMap(data), {
        'blob': {r'$t': 'Blob', r'$v': null}
      });

      data.setBlob("blob", null);
      expect(documentDataToJsonMap(data), {'blob': null});

      data.setBlob("blob", new Blob(new Uint8List.fromList([1, 2, 3])));
      expect(documentDataToJsonMap(data), {
        'blob': {r'$t': 'Blob', r'$v': 'AQID'}
      });
      data = documentDataFromJsonMap(firestore, documentDataToJsonMap(data));
      var blob = data.getBlob('blob');
      expect(blob.data, [1, 2, 3]);
    });

    test('geoPoint', () {
      var data = new DocumentData();
      data.setGeoPoint("geo", new GeoPoint(3.5, 4.0));
      expect(documentDataToJsonMap(data), {
        'geo': {
          r'$t': 'GeoPoint',
          r'$v': {'latitude': 3.5, 'longitude': 4.0}
        }
      });

      data.setGeoPoint("geo", null);
      expect(documentDataToJsonMap(data), {'geo': null});

      data.setGeoPoint("geo", new GeoPoint(3.5, 4.0));

      data = documentDataFromJsonMap(firestore, documentDataToJsonMap(data));
      var geoPoint = data.getGeoPoint('geo');
      expect(geoPoint.latitude, 3.5);
      expect(geoPoint.longitude, 4.0);
    });

    test('documentReference', () {
      var data = new DocumentData();
      data.setDocumentReference("ref", firestore.doc('tests/doc'));
      expect(documentDataToJsonMap(data), {
        'ref': {r'$t': 'DocumentReference', r'$v': 'tests/doc'}
      });
      data.setDocumentReference("ref", null);
      expect(documentDataToJsonMap(data), {'ref': null});
      data = documentDataFromJsonMap(firestore, documentDataToJsonMap(data));
      var ref = data.getDocumentReference('ref');
      expect(ref, null);
    });

    test('toJsonMap', () {
      var documentData = new DocumentDataMap();
      expect(documentDataToJsonMap(documentData), {});
      documentData.setInt('int', 1);
      var nested = new DocumentData();
      nested.setFieldValue('delete', FieldValue.delete);
      documentData.setList('list', [
        1,
        new DateTime.fromMillisecondsSinceEpoch(1234567890123),
        FieldValue.serverTimestamp
      ]);
      documentData.setFieldValue('delete', FieldValue.delete);
      documentData.setData('nested', nested);
      expect(documentDataToJsonMap(documentData), {
        'int': 1,
        'list': [
          1,
          {r'$t': 'DateTime', r'$v': '2009-02-13T23:31:30.123Z'},
          {r'$t': 'FieldValue', r'$v': '~serverTimestamp'}
        ],
        'delete': {r'$t': 'FieldValue', r'$v': '~delete'},
        'nested': {
          'delete': {r'$t': 'FieldValue', r'$v': '~delete'}
        }
      });
    });

    test('fromJsonMap', () {
      var map = {
        'data': {
          'list': [
            "test",
            null,
            {r'$t': 'DateTime', r'$v': '5882-03-08T14:08:21.234Z'}
          ],
          'int': 1,
          'delete': {r'$t': 'FieldValue', r'$v': '~delete'},
          'ref': {r'$t': 'DocumentReference', r'$v': 'tests/doc'}
        }
      };
      expect(
          documentDataToJsonMap(documentDataFromJsonMap(firestore, map)), map);
    });
  });
}
