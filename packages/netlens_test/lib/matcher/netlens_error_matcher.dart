import 'package:netlens/model/netlens_http_error.dart';
import 'package:test/test.dart';

TypeMatcher<NetLensHttpError> buildErrorMatcher({
  bool? checkError,
  bool? checkStacktrace,
}) {
  var matcher = const TypeMatcher<NetLensHttpError>();
  if (checkError == true) {
    matcher = matcher.having(
      (error) => error.error.toString(),
      "error",
      isNotEmpty,
    );
  }
  if (checkStacktrace == true) {
    matcher = matcher.having(
      (error) => error.stackTrace.toString(),
      "stackTrace",
      isNotEmpty,
    );
  }

  return matcher;
}
