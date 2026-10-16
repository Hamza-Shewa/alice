import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';

class MockedData {
  static NetLensHttpCall getHttpCallWithResponseStatus({
    required int statusCode,
  }) {
    final httpCall = NetLensHttpCall(DateTime.now().millisecondsSinceEpoch)
      ..loading = false;
    httpCall.request = NetLensHttpRequest();
    httpCall.response = NetLensHttpResponse()..status = statusCode;
    return httpCall;
  }

  static NetLensHttpCall getLoadingHttpCall() {
    final httpCall = NetLensHttpCall(DateTime.now().millisecondsSinceEpoch);
    return httpCall;
  }

  static NetLensHttpCall getHttpCall({required int id}) {
    final httpCall = NetLensHttpCall(id);
    return httpCall;
  }

  static NetLensHttpCall getFilledHttpCall() =>
      NetLensHttpCall(DateTime.now().microsecondsSinceEpoch)
        ..loading = false
        ..request =
            (NetLensHttpRequest()
              ..headers = {}
              ..body = '{"id": 0}'
              ..contentType = "application/json"
              ..size = 0
              ..time = DateTime.now())
        ..response =
            (NetLensHttpResponse()
              ..headers = {}
              ..body = '{"id": 0}'
              ..size = 0
              ..time = DateTime.now())
        ..method = "POST"
        ..endpoint = "/test"
        ..server = "https://test.com"
        ..secure = true;
}
