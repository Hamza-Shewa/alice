import 'dart:async' show FutureOr;
import 'dart:convert' show utf8;
import 'dart:io' show HttpHeaders;

import 'package:netlens/model/netlens_form_data_file.dart';
import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:flutter/foundation.dart';
import 'package:netlens/core/netlens_adapter.dart';
import 'package:netlens/core/netlens_utils.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_log.dart';
import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class NetLensChopperAdapter with NetLensAdapter implements Interceptor {
  /// Creates hashcode based on request
  int getRequestHashCode(http.BaseRequest baseRequest) {
    final int hashCodeSum =
        baseRequest.url.hashCode +
        baseRequest.method.hashCode +
        baseRequest.headers.entries.fold<int>(
          0,
          (int previousValue, MapEntry<String, String> header) =>
              previousValue + header.key.hashCode + header.value.hashCode,
        ) +
        (baseRequest.contentLength?.hashCode ?? 0);

    return hashCodeSum.hashCode;
  }

  /// Handles chopper request and creates netLens http call
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final int requestId = getRequestHashCode(
      /// The netlens_token header is added to the request in order to keep track
      /// of the request in the NetLensCore instance.
      applyHeader(chain.request, 'netlens_token', const Uuid().v4()),
    );

    netLensCore.addCall(
      NetLensHttpCall(requestId)
        ..method = chain.request.method
        ..endpoint =
            chain.request.url.path.isEmpty ? '/' : chain.request.url.path
        ..server = chain.request.url.host
        ..secure = chain.request.url.scheme == 'https'
        ..uri = chain.request.url.toString()
        ..client = 'Chopper'
        ..request =
            (NetLensHttpRequest()
              ..size = switch (chain.request.body) {
                dynamic body when body is String => utf8.encode(body).length,
                dynamic body when body is List<int> => body.length,
                dynamic body when body == null => 0,
                _ => utf8.encode(body.toString()).length,
              }
              ..body = chain.request.body ?? ''
              ..time = DateTime.now()
              ..headers = chain.request.headers
              ..contentType =
                  chain.request.headers[HttpHeaders.contentTypeHeader] ??
                  'unknown'
              ..formDataFields =
                  chain.request.parts
                      .whereType<PartValue>()
                      .map(
                        (field) =>
                            NetLensFormDataField(field.name, field.value),
                      )
                      .toList()
              ..formDataFiles =
                  chain.request.parts
                      .whereType<PartValueFile>()
                      .map((file) => NetLensFormDataFile(file.value, "", 0))
                      .toList()
              ..queryParameters = chain.request.parameters)
        ..response = NetLensHttpResponse(),
    );

    try {
      final Response<BodyType> response = await chain.proceed(chain.request);

      netLensCore.addResponse(
        NetLensHttpResponse()
          ..status = response.statusCode
          ..body = response.body ?? ''
          ..size = switch (response.body) {
            dynamic body when body is String => utf8.encode(body).length,
            dynamic body when body is List<int> => body.length,
            dynamic body when body == null => 0,
            _ => utf8.encode(body.toString()).length,
          }
          ..time = DateTime.now()
          ..headers = <String, String>{
            for (final MapEntry<String, String> entry
                in response.headers.entries)
              entry.key: entry.value,
          },
        requestId,
      );

      if (!response.isSuccessful || response.error != null) {
        netLensCore.addError(
          NetLensHttpError()..error = response.error,
          requestId,
        );
      }

      return response;
    } catch (error, stackTrace) {
      /// Log error to NetLens log
      NetLensUtils.log(error.toString());

      netLensCore.addLog(
        NetLensLog(
          message: error.toString(),
          level: DiagnosticLevel.error,
          error: error,
          stackTrace: stackTrace,
        ),
      );

      /// Add empty response to NetLens core
      netLensCore.addResponse(NetLensHttpResponse()..status = -1, requestId);

      /// Add error to NetLens core
      netLensCore.addError(
        NetLensHttpError()
          ..error = error
          ..stackTrace = stackTrace,
        requestId,
      );

      /// Rethrow error
      rethrow;
    }
  }
}
