DateTime dateTimeParseTimestamp(String text) {
  if (text != null) {
    // 2018-10-20T05:13:45.985343Z
    var dateTime = DateTime.tryParse(text);
    if (dateTime != null) {
      return dateTime;
    }
    if (_hasNanosecondPrecision(text)) {
      var len = text.length;
      text = '${text.substring(0, len - 4)}Z';
      return dateTimeParseTimestamp(text);
    }
    /*
    var len = text.length;
    if ((text[len - 1] == 'Z') && (len > 12) && text[len - 8] == '.') {
      text = '${text.substring(0, len - 4)}Z';
      print(text);
    }
    */
  }
  return null;
}

bool _hasNanosecondPrecision(String text) {
  if (text != null) {
    var len = text.length;
    if ((text[len - 1] == 'Z') && (len > 15) && text[len - 11] == '.') {
      return true;
    }
  }
  return false;
}

bool _hasMicrosecondPrecision(String text) {
  if (text != null) {
    var len = text.length;
    if ((text[len - 1] == 'Z') && (len > 12) && text[len - 8] == '.') {
      return true;
    }
  }
  return false;
}

bool _hasMillisecondPrecision(String text) {
  if (text != null) {
    var len = text.length;
    if ((text[len - 1] == 'Z') && (len > 9) && text[len - 5] == '.') {
      return true;
    }
  }
  return false;
}

String dateTimeToTimestampMicros(DateTime dateTime) {
  if (dateTime != null) {
    var text = dateTime.toIso8601String();
    if (_hasMicrosecondPrecision(text)) {
      return text;
    } else if (_hasMillisecondPrecision(text)) {
      var len = text.length;
      return '${text.substring(0, len - 1)}000Z';
    }
    return text;
  }
  return null;
}

// Copied from sembast
const updateTimeKey = r'$updateTime';
const createTimeKey = r'$createTime';

const minUpdateTime = '2018-10-23T00:00:00.000000Z';
const minCreateTime = '2018-10-23T00:00:00.000000Z';

String mapUpdateTime(Map<String, dynamic> recordMap) => recordMap != null
    ? ((recordMap[updateTimeKey] as String) ?? minUpdateTime)
    : null;
String mapCreateTime(Map<String, dynamic> recordMap) => recordMap != null
    ? ((recordMap[createTimeKey] as String) ?? minCreateTime)
    : null;
