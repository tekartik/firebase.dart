import 'package:tekartik_firebase/src/firestore.dart';

bool get _runningAsJavascript => identical(1, 1.0);

bool get dateTimeHasMicros => !_runningAsJavascript;

// Copied from sembast
const updateTimeKey = r'$updateTime';
const createTimeKey = r'$createTime';

const minUpdateTime = '2018-10-23T00:00:00.000000Z';
const minCreateTime = '2018-10-23T00:00:00.000000Z';

Timestamp mapUpdateTime(Map<String, dynamic> recordMap) => recordMap != null
    ? Timestamp.tryParse((recordMap[updateTimeKey] as String) ?? minUpdateTime)
    : null;
Timestamp mapCreateTime(Map<String, dynamic> recordMap) => recordMap != null
    ? Timestamp.tryParse((recordMap[createTimeKey] as String) ?? minCreateTime)
    : null;
