import 'dart:io' show Cookie;

import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';

/// Copies of the call models. They are extensions instead of methods, because
/// storages implement the models (for example the ObjectBox entities) and
/// would have to implement every new method too.
extension AliceHttpCallCopy on AliceHttpCall {
  /// Returns a copy of this call. Request, response and error are copied too,
  /// so the copy can be changed without changing the stored call.
  AliceHttpCall copy() =>
      AliceHttpCall(id, createdTime: createdTime)
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

extension AliceHttpRequestCopy on AliceHttpRequest {
  /// Returns a copy of this request with copied collections.
  AliceHttpRequest copy() =>
      AliceHttpRequest()
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
                : List<AliceFormDataFile>.of(formDataFiles!)
        ..formDataFields =
            formDataFields == null
                ? null
                : List<AliceFormDataField>.of(formDataFields!);
}

extension AliceHttpResponseCopy on AliceHttpResponse {
  /// Returns a copy of this response with copied headers.
  AliceHttpResponse copy() =>
      AliceHttpResponse()
        ..status = status
        ..size = size
        ..time = time
        ..body = body
        ..headers = headers == null ? null : Map<String, String>.of(headers!);
}

extension AliceHttpErrorCopy on AliceHttpError {
  /// Returns a copy of this error.
  AliceHttpError copy() =>
      AliceHttpError()
        ..error = error
        ..stackTrace = stackTrace;
}
