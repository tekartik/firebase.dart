import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:test/test.dart';

bool skipConcurrentTransactionTests = false;

void run(Firebase firebase, {AppOptions options}) {
  App app = firebase.initializeApp(options: options);

  tearDownAll(() {
    return app.delete();
  });

  runApp(firebase, app);
}

runApp(Firebase firebase, App app) {
  group('firestore', () {
    var testsRefPath = 'tests/firebase_shim/tests';

    CollectionReference getTestsRef() {
      return app.firestore().collection(testsRefPath);
    }

    group('DocumentReference', () {
      test('create', () async {
        var ref =
            app.firestore().doc(url.join(testsRefPath, "document_reference"));
        try {
          await ref.delete();
        } catch (_) {}

        await ref.set({});

        await ref.delete();
      });

      test('collection_add', () async {
        var testsRef = getTestsRef();

        var docRef = await testsRef.add({});
        await docRef.delete();
      });

      /*
      // this does not work on node
      test('collection_child_no_path', () async {
        var testsRef = getTestsRef();

        var docRef = testsRef.doc();
        expect(docRef.id, isNotNull);
        expect(docRef.id, isNotEmpty);
      }, skip: platform.name == platformNameNode);
      */

      test('get_dummy', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('dummy_id_that_should_never_exists');
        var snapshot = await docRef.get();
        expect(snapshot.exists, isFalse);
      });

      test('delete', () async {
        var testsRef = getTestsRef();
        var docRef = await testsRef.add({});
        await docRef.delete();

        var snapshot = await docRef.get();
        expect(snapshot.exists, isFalse);
      });
    });

    group("DocumentData", () {
      test('property', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('property');
        var documentData = new DocumentData();
        expect(documentData.has("some_property"), isFalse);
        expect(documentData.keys, isEmpty);
        documentData.setProperty("some_property", "test_1");
        expect(documentData.keys, ["some_property"]);
        expect(documentData.has("some_property"), isTrue);
        await docRef.set(documentData.asMap());
        documentData = new DocumentData((await docRef.get()).data);
        expect(documentData.has("some_property"), isTrue);
        expect(documentData.keys, ["some_property"]);
        expect(documentData.has("other_property"), isFalse);
        await docRef.delete();
      });

      // All fields that we do not delete
      test('allFields', () async {
        var testsRef = getTestsRef();
        var localDateTime = new DateTime.fromMillisecondsSinceEpoch(1234567890);
        var utcDateTime =
            new DateTime.fromMillisecondsSinceEpoch(1234567890, isUtc: true);
        var docRef = testsRef.doc('all_fields');
        var documentData = new DocumentData();
        documentData.setString("string", "string_value");

        documentData.setInt("int", 12345678901);
        documentData.setNum("num", 3.1416);
        documentData.setBool("bool", true);
        documentData.setDateTime("localDateTime", localDateTime);
        documentData.setDateTime("utcDateTime", utcDateTime);
        documentData.setList('intList', <int>[4, 3]);
        documentData.setDocumentReference(
            'docRef', app.firestore().doc('tests/doc'));
        documentData.setBlob(
            'blob', new Blob(new Uint8List.fromList([1, 2, 3])));
        documentData.setGeoPoint('geoPoint', new GeoPoint(1.2, 4));

        documentData.setFieldValue(
            "serverTimestamp", FieldValue.serverTimestamp);

        var subData = new DocumentData();
        subData.setDateTime("localDateTime", localDateTime);
        documentData.setData("subData", subData);

        var subSubData = new DocumentData();
        subData.setData("inner", subSubData);

        await docRef.set(documentData.asMap());
        documentData = new DocumentData((await docRef.get()).data);
        expect(documentData.getString("string"), "string_value");

        expect(documentData.getInt("int"), 12345678901);
        expect(documentData.getNum("num"), 3.1416);
        expect(documentData.getBool("bool"), true);

        expect(documentData.getDateTime("localDateTime"), localDateTime);
        expect(documentData.getDateTime("utcDateTime"), utcDateTime.toLocal());
        expect(documentData.getDocumentReference('docRef').path, 'tests/doc');
        expect(documentData.getBlob('blob').data, [1, 2, 3]);
        expect(documentData.getGeoPoint('geoPoint'), new GeoPoint(1.2, 4));
        expect(
            documentData.getDateTime("serverTimestamp").millisecondsSinceEpoch >
                0,
            isTrue);
        List<int> list = documentData.getList('intList');
        expect(list, [4, 3]);

        subData = documentData.getData("subData");
        expect(subData.getDateTime("localDateTime"), localDateTime);

        subSubData = subData.getData("inner");
        expect(subSubData, isNotNull);
      });
    });
    group("Data", () {
      test('string', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('string');
        await docRef.set({"some_key": "some_value"});
        expect((await docRef.get()).data, {"some_key": "some_value"});
        await docRef.delete();
      });

      test('date', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('date');
        var localDateTime =
            new DateTime.fromMillisecondsSinceEpoch(1234567890).toLocal();
        var utcDateTime =
            new DateTime.fromMillisecondsSinceEpoch(12345678901).toUtc();
        await docRef
            .set({"some_date": localDateTime, "some_utc_date": utcDateTime});
        expect((await docRef.get()).data, {
          "some_date": localDateTime,
          "some_utc_date": utcDateTime.toLocal()
        });
        await docRef.delete();
      });

      // All fields that we do not delete
      test('allFields', () async {
        var testsRef = getTestsRef();
        var localDateTime = new DateTime.fromMillisecondsSinceEpoch(1234567890);
        var utcDateTime =
            new DateTime.fromMillisecondsSinceEpoch(1234567890, isUtc: true);
        var docRef = testsRef.doc('all_fields');
        var data = {
          "string": "string_value",
          "int": 12345678901,
          "num": 3.1416,
          "bool": true,
          "localDateTime": localDateTime,
          "utcDateTime": utcDateTime,
          'intList': <int>[4, 3],
          'docRef': app.firestore().doc('tests/doc'),
          'blob': new Blob(new Uint8List.fromList([1, 2, 3])),
          'geoPoint': new GeoPoint(1.2, 4),
          "serverTimestamp": FieldValue.serverTimestamp,
          "subData": {
            "localDateTime": localDateTime,
            "inner": {'int': 1234}
          }
        };

        await docRef.set(data);
        data = (await docRef.get()).data;
        expect((data['serverTimestamp'] as DateTime).isUtc, isFalse);
        expect((data['docRef'] as DocumentReference).path, 'tests/doc');
        data.remove('serverTimestamp');
        data.remove('docRef');
        expect(data, {
          "string": "string_value",
          "int": 12345678901,
          "num": 3.1416,
          "bool": true,
          "localDateTime": localDateTime,
          "utcDateTime": utcDateTime.toLocal(),
          'intList': <int>[4, 3],
          'blob': new Blob(new Uint8List.fromList([1, 2, 3])),
          'geoPoint': new GeoPoint(1.2, 4),
          "subData": {
            "localDateTime": localDateTime,
            "inner": {'int': 1234}
          }
        });
      });

      test('deleteField', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc("delete_field");
        var data = <String, dynamic>{
          "some_key": "some_value",
          "other_key": "other_value"
        };
        await docRef.set(data);
        data = (await docRef.get()).data;
        expect(data, {"some_key": "some_value", "other_key": "other_value"});

        data = {"some_key": FieldValue.delete};
        await docRef.update(data);
        data = (await docRef.get()).data;
        expect(data, {"other_key": "other_value"});
      });

      //test('subData')
    });

    group('DocumentReference', () {
      test('attributes', () {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('document_test_attributes');
        expect(docRef.id, "document_test_attributes");
        expect(docRef.path, "${testsRef.path}/document_test_attributes");
        expect(docRef.parent, const TypeMatcher<CollectionReference>());
        expect(docRef.parent.id, "tests");
      });

      test('onSnapshot', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('onSnapshot');

        // delete it
        await docRef.delete();

        int stepCount = 4;
        var completers = new List.generate(
            stepCount, (_) => new Completer<DocumentSnapshot>());
        int count = 0;
        var subscription =
            docRef.onSnapshot().listen((DocumentSnapshot documentSnapshot) {
          if (count < stepCount) {
            completers[count++].complete(documentSnapshot);
          }
        });
        int index = 0;
        // wait for receiving first data
        var snapshot = await completers[index++].future;
        expect(snapshot.exists, isFalse);

        // create it
        docRef.set({});
        // wait for receiving change data
        snapshot = await completers[index++].future;
        expect(snapshot.exists, isTrue);
        expect(snapshot.data, {});

        // modify it
        docRef.set({'value': 1});
        // wait for receiving change data
        snapshot = await completers[index++].future;
        expect(snapshot.exists, isTrue);
        expect(snapshot.data, {'value': 1});

        // delete it
        await docRef.delete();
        // wait for receiving change data
        snapshot = await completers[index++].future;
        expect(snapshot.exists, isFalse);

        await subscription.cancel();
      });

      test('SetOptions', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('setOptions');

        await docRef.set({'value1': 1, 'value2': 2});
        // Set with merge, value1 should remain
        await docRef.set({'value2': 3}, new SetOptions(merge: true));
        var readData = (await docRef.get()).data;
        expect(readData, {'value1': 1, 'value2': 3});

        // Set without merge, value1 should be gone
        await docRef.set({'value2': 4});
        readData = (await docRef.get()).data;
        expect(readData, {'value2': 4});
      });
    });

    group('CollectionReference', () {
      test('attributes', () {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('collection_test').collection('attributes');
        expect(collRef.id, "attributes");
        expect(collRef.path, "${testsRef.path}/collection_test/attributes");
        expect(collRef.parent, const TypeMatcher<DocumentReference>());
        expect(collRef.parent.id, "collection_test");

        // it seems the parent is not null as expected here...
        // however the path is empty...
        // Not supported on browser
        // expect(app.firestore().collection("tests").parent.path, '');
        // Not supported on browser
        // expect(app.firestore().collection("/tests").parent.path, '');
      });

      test('empty', () async {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('collection_test').collection('empty');
        QuerySnapshot querySnapshot = await collRef.get();
        var list = querySnapshot.docs;
        expect(list, isEmpty);
      });

      test('single', () async {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('collection_test').collection('single');
        var docRef = collRef.doc('one');
        await docRef.set({});
        QuerySnapshot querySnapshot = await collRef.get();
        var list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "one");
      });

      test('select', () async {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('collection_test').collection('select');
        var docRef = collRef.doc('one');
        await docRef.set({'field1': 1, 'field2': 2});
        QuerySnapshot querySnapshot = await collRef.select(['field1']).get();
        var data = querySnapshot.docs.first.data;
        if (firebase.firestore.supportsQuerySelect) {
          expect(data, {'field1': 1});
        } else {
          expect(data, {'field1': 1, 'field2': 2});
        }
        querySnapshot = await collRef.select(['field2']).get();
        data = querySnapshot.docs.first.data;
        if (firebase.firestore.supportsQuerySelect) {
          expect(data, {'field2': 2});
        } else {
          expect(data, {'field1': 1, 'field2': 2});
        }
        querySnapshot = await collRef.select(['field1', 'field2']).get();
        data = querySnapshot.docs.first.data;
        expect(data, {'field1': 1, 'field2': 2});
      });

      test('complex', () async {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('collection_test').collection('many');
        var docRefOne = collRef.doc('one');
        List<DocumentSnapshot> list;
        await docRefOne.set({
          'value': 1,
          'date': new DateTime.fromMillisecondsSinceEpoch(2),
          'sub': {'value': 'b'}
        });
        var docRefTwo = collRef.doc('two');
        await docRefTwo.set({
          'value': 2,
          'date': new DateTime.fromMillisecondsSinceEpoch(1),
          'sub': {'value': 'a'}
        });
        // limit
        QuerySnapshot querySnapshot = await collRef.limit(1).get();
        list = querySnapshot.docs;
        expect(list.length, 1);

        /*
        // offset
        querySnapshot = await collRef.orderBy('value').offset(1).get();
        list = querySnapshot.docs;
        expect(list.length, 1);
        */

        // order by
        querySnapshot = await collRef.orderBy('value').get();
        list = querySnapshot.docs;
        expect(list.length, 2);
        expect(list.first.ref.id, "one");

        // order by date
        querySnapshot = await collRef.orderBy('date').get();
        list = querySnapshot.docs;
        expect(list.length, 2);
        expect(list.first.ref.id, "two");

        // order by sub field
        querySnapshot = await collRef.orderBy('sub.value').get();
        list = querySnapshot.docs;
        expect(list.length, 2);
        expect(list.first.ref.id, "two");

        // desc
        querySnapshot = await collRef.orderBy('value', descending: true).get();
        list = querySnapshot.docs;
        expect(list.length, 2);
        expect(list.first.ref.id, "two");

        // start at
        querySnapshot =
            await collRef.orderBy('value').startAt(values: [2]).get();
        list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "two");

        // start after
        querySnapshot =
            await collRef.orderBy('value').startAfter(values: [1]).get();
        list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "two");

        // end at
        querySnapshot = await collRef.orderBy('value').endAt(values: [1]).get();
        list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "one");

        // end before
        querySnapshot =
            await collRef.orderBy('value').endBefore(values: [2]).get();
        list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "one");

        // start after using snapshot
        querySnapshot = await collRef
            .orderBy('value')
            .startAfter(snapshot: list.first)
            .get();
        list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "two");

        // where
        querySnapshot = await collRef.where('value', isGreaterThan: 1).get();
        list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "two");
      });

      test('onSnapshot', () async {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('query_test').collection('onSnapshot');

        var docRef = collRef.doc('item');
        // delete it
        await docRef.delete();

        var completer1 = new Completer();
        var completer2 = new Completer();
        var completer3 = new Completer();
        var completer4 = new Completer();
        int count = 0;
        var subscription =
            collRef.onSnapshot().listen((QuerySnapshot querySnapshot) {
          if (++count == 1) {
            // first step ignore the result
            completer1.complete();
          } else if (count == 2) {
            // second step expect an added item
            expect(querySnapshot.documentChanges.length, 1);
            expect(querySnapshot.documentChanges.first.type,
                DocumentChangeType.added);

            completer2.complete();
          } else if (count == 3) {
            // second step expect a modified item
            expect(querySnapshot.documentChanges.length, 1);
            expect(querySnapshot.documentChanges.first.type,
                DocumentChangeType.modified);

            completer3.complete();
          } else if (count == 4) {
            // second step expect a deletion
            expect(querySnapshot.documentChanges.length, 1);
            expect(querySnapshot.documentChanges.first.type,
                DocumentChangeType.removed);

            completer4.complete();
          }
        });
        // wait for receiving first data
        await completer1.future;

        // create it
        docRef.set({});

        // wait for receiving change data
        await completer2.future;

        // modify it
        docRef.set({'value': 1});

        // wait for receiving change data
        await completer3.future;

        // delete it
        await docRef.delete();

        // wait for receiving change data
        await completer4.future;

        await subscription.cancel();
      });
    });

    group('WriteBatch', () {
      test('create_delete', () async {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('batch_test').collection('delete');

        var deleteRef = collRef.doc('delete');
        var createRef = collRef.doc('create');
        // create it
        await deleteRef.set({});
        await createRef.delete();

        expect((await deleteRef.get()).exists, isTrue);
        expect((await createRef.get()).exists, isFalse);

        var batch = app.firestore().batch();
        batch.delete(deleteRef);
        batch.set(createRef, {});
        await batch.commit();

        expect((await deleteRef.get()).exists, isFalse);
        expect((await createRef.get()).exists, isTrue);
      });

      group('all', () {
        test('batch', () async {
          var collRef = getTestsRef().doc('batch_test').collection('all');
          // this one will be created
          var doc1Ref = collRef.doc('item1');
          // this one will be updated
          var doc2Ref = collRef.doc('item2');
          // this one will be set
          var doc3Ref = collRef.doc('item3');
          // this one will be deleted
          var doc4Ref = collRef.doc('item4');

          await doc1Ref.delete();
          await doc2Ref.set({'value': 2});
          await doc4Ref.set({'value': 4});

          var batch = app.firestore().batch();
          batch.set(doc1Ref, {'value': 1});
          batch.update(doc2Ref, {'other.value': 2});
          batch.set(doc3Ref, {'value': 3});
          batch.delete(doc4Ref);
          await batch.commit();

          expect((await doc1Ref.get()).data, {'value': 1});
          //expect((await doc2Ref.get()).data().toMap(), {'value': 2, 'other.value': 2});
          expect((await doc3Ref.get()).data, {'value': 3});
          expect((await doc4Ref.get()).exists, isFalse);
        });
      });

      group('Transaction', () {
        test('concurrent_get_update', () async {
          var testsRef = getTestsRef();
          var collRef =
              testsRef.doc('transaction_test').collection('get_update');
          var ref = collRef.doc("item");
          await ref.set({"value": 1});

          int modifiedCount = 0;
          await app.firestore().runTransaction((txn) async {
            var data = (await txn.get(ref)).data;
            // devPrint('get ${data}');
            if (modifiedCount++ == 0) {
              await ref.set({"value": 10});
            }

            data["value"] = (data["value"] as int) + 1;
            txn.update(ref, data);
          });

          // we should run the transaction twice...
          expect(modifiedCount, 2);

          expect((await ref.get()).data, {"value": 11});
        }, skip: skipConcurrentTransactionTests);

        test('get_update', () async {
          var testsRef = getTestsRef();
          var collRef =
              testsRef.doc('transaction_test').collection('get_update');
          var ref = collRef.doc("item");
          await ref.set({"value": 1});

          await app.firestore().runTransaction((txn) async {
            var data = (await txn.get(ref)).data;

            data["value"] = (data["value"] as int) + 1;
            txn.set(ref, data);
          });

          expect((await ref.get()).data, {"value": 2});
        });

        // make sure that after the transaction we're still fine
        test('post_transaction_set', () async {
          var testsRef = getTestsRef();
          var collRef =
              testsRef.doc('transaction_test').collection('get_update');
          var ref = collRef.doc("item");
          await ref.set({"value": 1});
        });
      });
      // TODO implement
    });
    test('bug_limit', () async {
      var query = await app
          .firestore()
          .collection("tests")
          .doc("firebase_shim_test")
          .collection("tests")
          .orderBy("timestamp")
          .limit(10)
          .select([]);
      expect((await query.get()).docs, isNotEmpty);
    }, skip: true);
  });
}
