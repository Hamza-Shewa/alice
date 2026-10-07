import 'dart:convert';

import 'package:alice/core/alice_adapter.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AliceDioAdapter extends InterceptorsWrapper with AliceAdapter {
  /// Handles dio request and creates alice http call based on it
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final call = AliceHttpCall(options.hashCode);

    // A typo in base URL or path (e.g. "http://host:505" + "api/login")
    // makes the URL unparsable. Record the call anyway, so Alice can show
    // what went wrong instead of silently dropping it.
    final Uri? uri = _tryGetUri(options);
    call.method = options.method;
    if (uri != null) {
      var path = uri.path;
      if (path.isEmpty) {
        path = '/';
      }
      call
        ..endpoint = path
        ..server = uri.host
        ..uri = uri.toString()
        ..secure = uri.scheme == 'https';
    } else {
      final rawUrl = _getRawUrl(options);
      final match = RegExp(
        r'^(?:([a-zA-Z][a-zA-Z0-9+.-]*):\/\/)?([^\/?#]*)(.*)$',
      ).firstMatch(rawUrl);
      final path = match?.group(3) ?? '';
      call
        ..endpoint = path.isEmpty ? '/' : path
        ..server = match?.group(2) ?? ''
        ..uri = rawUrl
        ..secure = match?.group(1) == 'https';
    }
    call.client = 'Dio';

    final request = AliceHttpRequest();

    final dynamic data = options.data;
    if (data == null) {
      request
        ..size = 0
        ..body = '';
    } else {
      if (data is FormData) {
        // ignore: avoid_dynamic_calls
        request.body += 'Form data';

        if (data.fields.isNotEmpty == true) {
          final fields = <AliceFormDataField>[];
          for (var entry in data.fields) {
            fields.add(AliceFormDataField(entry.key, entry.value));
          }
          request.formDataFields = fields;
        }

        if (data.files.isNotEmpty == true) {
          final files = <AliceFormDataFile>[];
          for (var entry in data.files) {
            files.add(
              AliceFormDataFile(
                entry.value.filename,
                entry.value.contentType.toString(),
                entry.value.length,
              ),
            );
          }

          request.formDataFiles = files;
        }
      } else {
        request
          ..size = utf8.encode(data.toString()).length
          ..body = data;
      }
    }

    request
      ..time = DateTime.now()
      ..headers = AliceParser.parseHeaders(headers: options.headers)
      ..contentType = options.contentType.toString()
      ..queryParameters = uri?.queryParameters ?? options.queryParameters;

    call
      ..request = request
      ..response = AliceHttpResponse();

    aliceCore.addCall(call);
    handler.next(options);
  }

  /// Returns [options] URI or null when the URL can't be parsed.
  Uri? _tryGetUri(RequestOptions options) {
    try {
      return options.uri;
    } on FormatException {
      return null;
    }
  }

  /// Returns URL built the same way as [RequestOptions.uri], but without
  /// parsing it.
  String _getRawUrl(RequestOptions options) {
    final path = options.path;
    if (path.startsWith(RegExp(r'https?:'))) {
      return path;
    }
    return options.baseUrl + path;
  }

  /// Handles dio response and adds data to alice http call
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final httpResponse = AliceHttpResponse()..status = response.statusCode;

    if (response.data == null) {
      httpResponse
        ..body = ''
        ..size = 0;
    } else {
      httpResponse
        ..body = response.data
        ..size = utf8.encode(response.data.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final headers = <String, String>{};
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;

    aliceCore.addResponse(httpResponse, response.requestOptions.hashCode);
    handler.next(response);
  }

  /// Handles error and adds data to alice http call
  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final httpError = AliceHttpError()..error = error.toString();
    if (error is Error) {
      final basicError = error as Error;
      httpError.stackTrace = basicError.stackTrace;
    }

    aliceCore.addError(httpError, error.requestOptions.hashCode);
    final httpResponse = AliceHttpResponse()..time = DateTime.now();
    if (error.response == null) {
      httpResponse.status = -1;
      aliceCore.addResponse(httpResponse, error.requestOptions.hashCode);
    } else {
      httpResponse.status = error.response!.statusCode;

      if (error.response!.data == null) {
        httpResponse
          ..body = ''
          ..size = 0;
      } else {
        httpResponse
          ..body = error.response!.data
          ..size = utf8.encode(error.response!.data.toString()).length;
      }
      final headers = <String, String>{};
      error.response!.headers.forEach((header, values) {
        headers[header] = values.toString();
      });
      httpResponse.headers = headers;
      aliceCore.addResponse(
        httpResponse,
        error.response!.requestOptions.hashCode,
      );
      aliceCore.addLog(
        AliceLog(
          message: error.toString(),
          level: DiagnosticLevel.error,
          error: error,
          stackTrace: error.stackTrace,
        ),
      );
    }
    handler.next(error);
  }
}
