import 'dart:async';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:tekartik_firebase/firebase.dart';
import 'package:tekartik_firebase/firestore.dart';
import 'package:test/test.dart';

void run(Firebase firebase) {
  App app = firebase.initializeApp();

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
        var documentData = new DocumentData();
        try {
          await ref.delete();
        } catch (_) {
          //print(e);
          //devPrint(st);
        }

        await ref.set(documentData);

        await ref.delete();
      });

      test('collection_add', () async {
        var testsRef = getTestsRef();

        var documentData = new DocumentData();
        var docRef = await testsRef.add(documentData);
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

        var documentData = new DocumentData();
        var docRef = await testsRef.add(documentData);
        await docRef.delete();

        var snapshot = await docRef.get();
        expect(snapshot.exists, isFalse);
      });
    });

    group("DocumentData", () {
      test('string', () async {
        var testsRef = getTestsRef();
        var documentData = new DocumentData();
        documentData.setString("some_key", "some_value");
        var docRef = await testsRef.add(documentData);
        documentData = (await docRef.get()).data();
        expect(documentData.getString("some_key"), "some_value");
        await docRef.delete();
      });

      test('date', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('date');
        var localDateTime = new DateTime.fromMillisecondsSinceEpoch(1234567890);
        var documentData = new DocumentData();
        documentData.setDateTime("some_date", localDateTime);
        expect(documentData.getDateTime("some_date"), localDateTime);
        await docRef.set(documentData);
        documentData = (await docRef.get()).data();
        expect(documentData.getDateTime("some_date"), localDateTime);
        await docRef.delete();
      });

      test('property', () async {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('property');
        var documentData = new DocumentData();
        expect(documentData.has("some_property"), isFalse);
        expect(documentData.keys, isEmpty);
        documentData.setProperty("some_property", "test_1");
        expect(documentData.keys, ["some_property"]);
        expect(documentData.has("some_property"), isTrue);
        await docRef.set(documentData);
        documentData = (await docRef.get()).data();
        expect(documentData.has("some_property"), isTrue);
        expect(documentData.keys, ["some_property"]);
        expect(documentData.has("other_property"), isFalse);
        await docRef.delete();
      });

      test('sub_empty', () async {
        var documentData = new DocumentData();
        var subData = new DocumentData();
        documentData.setData("sub", subData);
        subData = documentData.getData("sub");
        expect(subData, isNotNull);
      });

      test('sub_one', () async {
        var documentData = new DocumentData();
        var subData = new DocumentData();
        documentData.setData("sub", subData);
        subData.setString("test", "test_value");
        subData = documentData.getData("sub");
        expect(subData.getString("test"), "test_value");
      });

      test('sub_sub_one', () async {
        var documentData = new DocumentData();
        var subData = new DocumentData();
        documentData.setData("sub", subData);
        var subSubData = new DocumentData();
        subData.setData("inner", subSubData);
        subSubData.setString("test", "test_value");
        subData = documentData.getData("sub");
        subSubData = subData.getData("inner");
        expect(subSubData.getString("test"), "test_value");
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

        await docRef.set(documentData);
        documentData = (await docRef.get()).data();
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

      test('deleteField', () async {
        var testsRef = getTestsRef();
        var documentData = new DocumentData();
        documentData.setString("some_key", "some_value");
        documentData.setString("other_key", "other_value");
        var docRef = await testsRef.add(documentData);
        documentData = (await docRef.get()).data();
        expect(documentData.getString("some_key"), "some_value");

        documentData.setFieldValue("some_key", FieldValue.delete);
        await docRef.update(documentData);
        documentData = (await docRef.get()).data();
        expect(documentData.getString("some_key"), isNull);
        expect(documentData.has("some_key"), isFalse);
        expect(documentData.getString("other_key"), "other_value");
      });

      //test('subData')
    });

    group('DocumentReference', () {
      test('attributes', () {
        var testsRef = getTestsRef();
        var docRef = testsRef.doc('document_test_attributes');
        expect(docRef.id, "document_test_attributes");
        expect(docRef.path, "${testsRef.path}/document_test_attributes");
        expect(docRef.parent, new isInstanceOf<CollectionReference>());
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
        docRef.set(new DocumentData());
        // wait for receiving change data
        snapshot = await completers[index++].future;
        expect(snapshot.exists, isTrue);
        expect(snapshot.data().toMap(), {});

        // modify it
        docRef.set(new DocumentData()..setInt('value', 1));
        // wait for receiving change data
        snapshot = await completers[index++].future;
        expect(snapshot.exists, isTrue);
        expect(snapshot.data().toMap(), {'value': 1});

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

        var documentData = new DocumentData();
        documentData.setInt('value1', 1);
        documentData.setInt('value2', 2);
        await docRef.set(documentData);

        documentData = new DocumentData();
        documentData.setInt('value2', 3);

        // Set with merge, value1 should remain
        await docRef.set(documentData, new SetOptions(merge: true));
        var readData = (await docRef.get()).data();
        expect(readData.toMap(), {'value1': 1, 'value2': 3});

        // Set without merge, value1 should be gone
        documentData.setInt('value2', 4);
        await docRef.set(documentData);
        readData = (await docRef.get()).data();
        expect(readData.toMap(), {'value2': 4});
      });
    });

    group('CollectionReference', () {
      test('attributes', () {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('collection_test').collection('attributes');
        expect(collRef.id, "attributes");
        expect(collRef.path, "${testsRef.path}/collection_test/attributes");
        expect(collRef.parent, new isInstanceOf<DocumentReference>());
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
        await docRef.set(new DocumentData());
        QuerySnapshot querySnapshot = await collRef.get();
        var list = querySnapshot.docs;
        expect(list.length, 1);
        expect(list.first.ref.id, "one");
      });

      test('select', () async {
        if (firebase.firestore.supportsQuerySelect) {
          var testsRef = getTestsRef();
          var collRef = testsRef.doc('collection_test').collection('select');
          var docRef = collRef.doc('one');
          await docRef.set(
              new DocumentData()..setInt('field1', 1)..setInt('field2', 2));
          QuerySnapshot querySnapshot = await collRef.select(['field2']).get();
          var documentdata = querySnapshot.docs.first.data();
          expect(documentdata.has('field2'), isTrue);
          expect(documentdata.has('field1'), isFalse);

          querySnapshot = await collRef.select(['field2']).get();
          documentdata = querySnapshot.docs.first.data();
          expect(documentdata.has('field2'), isTrue);
          expect(documentdata.has('field1'), isFalse);
        }
      });

      test('complex', () async {
        var testsRef = getTestsRef();
        var collRef = testsRef.doc('collection_test').collection('many');
        var docRefOne = collRef.doc('one');
        List<DocumentSnapshot> list;
        await docRefOne.set(new DocumentData()
          ..setInt('value', 1)
          ..setDateTime('date', new DateTime.fromMillisecondsSinceEpoch(2))
          ..setData('sub', new DocumentData()..setString('value', 'b')));
        var docRefTwo = collRef.doc('two');
        await docRefTwo.set(new DocumentData()
          ..setInt('value', 2)
          ..setDateTime('date', new DateTime.fromMillisecondsSinceEpoch(1))
          ..setData('sub', new DocumentData()..setString('value', 'a')));

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
        docRef.set(new DocumentData());

        // wait for receiving change data
        await completer2.future;

        // modify it
        docRef.set(new DocumentData()..setInt('value', 1));

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
        await deleteRef.set(new DocumentData());
        await createRef.delete();

        expect((await deleteRef.get()).exists, isTrue);
        expect((await createRef.get()).exists, isFalse);

        var batch = app.firestore().batch();
        batch.delete(deleteRef);
        batch.set(createRef, new DocumentData());
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
          await doc2Ref.set(new DocumentData()..setInt('value', 2));
          await doc4Ref.set(new DocumentData()..setInt('value', 4));

          var batch = app.firestore().batch();
          batch.set(doc1Ref, new DocumentData()..setInt('value', 1));
          batch.update(doc2Ref, new DocumentData()..setInt('other.value', 2));
          batch.set(doc3Ref, new DocumentData()..setInt('value', 3));
          batch.delete(doc4Ref);
          await batch.commit();

          expect((await doc1Ref.get()).data().toMap(), {'value': 1});
          //expect((await doc2Ref.get()).data().toMap(), {'value': 2, 'other.value': 2});
          expect((await doc3Ref.get()).data().toMap(), {'value': 3});
          expect((await doc4Ref.get()).exists, isFalse);
        });
      });

      group('Transaction', () {
        test('get_update', () async {
          var testsRef = getTestsRef();
          var collRef =
              testsRef.doc('transaction_test').collection('get_update');
          var ref = collRef.doc("item");
          await ref.set(new DocumentData()..setInt("value", 1));

          await app.firestore().runTransaction((txn) async {
            var data = (await txn.get(ref)).data();
            data..setInt("value", data.getInt("value") + 1);
            txn.update(ref, data);
          });

          expect((await ref.get()).data().getInt("value"), 2);
        });
      }, skip: true);
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
