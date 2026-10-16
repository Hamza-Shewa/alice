import 'dart:io' show Cookie;

import 'package:netlens/model/netlens_form_data_file.dart';
import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';

/// Copies of the call models. They are extensions instead of methods, because
/// storages implement the models (for example the ObjectBox entities) and
/// would have to implement every new method too.
extension NetLensHttpCallCopy on NetLensHttpCall {
  /// Returns a copy of this call. Request, response and error are copied too,
  /// so the copy can be changed without changing the stored call.
  NetLensHttpCall copy() =>
      NetLensHttpCall(id, createdTime: createdTime)
        ..client = client
        ..loading = loading
        ..secure = secure
        ..method = method
        ..endpoint = endpoint
        ..server = server
        ..uri = uri
        ..duration = duration
        ..request = request?.copy()
        ..response = response?.copy()
        ..error = error?.copy();
}

extension NetLensHttpRequestCopy on NetLensHttpRequest {
  /// Returns a copy of this request with copied collections.
  NetLensHttpRequest copy() =>
      NetLensHttpRequest()
        ..size = size
        ..time = time
        ..headers = Map<String, String>.of(headers)
        ..body = body
        ..contentType = contentType
        ..cookies = List<Cookie>.of(cookies)
        ..queryParameters = Map<String, dynamic>.of(queryParameters)
        ..formDataFiles =
            formDataFiles == null
                ? null
                : List<NetLensFormDataFile>.of(formDataFiles!)
        ..formDataFields =
            formDataFields == null
                ? null
                : List<NetLensFormDataField>.of(formDataFields!);
}

extension NetLensHttpResponseCopy on NetLensHttpResponse {
  /// Returns a copy of this response with copied headers.
  NetLensHttpResponse copy() =>
      NetLensHttpResponse()
        ..status = status
        ..size = size
        ..time = time
        ..body = body
        ..headers = headers == null ? null : Map<String, String>.of(headers!);
}

extension NetLensHttpErrorCopy on NetLensHttpError {
  /// Returns a copy of this error.
  NetLensHttpError copy() =>
      NetLensHttpError()
        ..error = error
        ..stackTrace = stackTrace;
}
