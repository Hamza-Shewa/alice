import 'package:netlens/model/netlens_log.dart';
import 'package:test/test.dart';

TypeMatcher<NetLensLog> buildLogMatcher({
  bool? checkMessage,
  bool? checkError,
  bool? checkStacktrace,
  bool? checkTime,
}) {
  var matcher = const TypeMatcher<NetLensLog>();
  if (checkMessage != null) {
    matcher = matcher.having((log) => log.message, "message", isNotEmpty);
  }
  if (checkError == true) {
    matcher = matcher.having(
      (log) => log.error.toString(),
      "error",
      isNotEmpty,
    );
  }
  if (checkStacktrace == true) {
    matcher = matcher.having(
      (log) => log.stackTrace.toString(),
      "stackTrace",
      isNotEmpty,
    );
  }
  if (checkTime == true) {
    matcher = matcher.having(
      (log) => log.timestamp.millisecondsSinceEpoch,
      "timestamp",
      isPositive,
    );
  }
  return matcher;
}
