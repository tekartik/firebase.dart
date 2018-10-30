## Test setup

 Use dart2 and set env variable
    
    npm install
    
## Test

    pub run build_runner test -- -p node
    pub run test -p node
    pub run test -p node test/firestore_node_test.dart

### Single test

    pub run build_runner test -- -p node .\test\firestore_node_test.dart

    pbr test -- -p -node test/storage_node_test.dart
    pbr test -- -p -node test/firestore_node_test.dart
    pbr test -- -p -node test/admin_node_test.dart