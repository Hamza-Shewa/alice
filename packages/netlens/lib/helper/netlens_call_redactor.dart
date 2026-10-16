import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Cookie;

import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_call_copy.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_redaction.dart';

/// Replaces sensitive values of calls, as described by [NetLensRedaction].
/// Calls are never changed: [redact] returns a redacted copy.
class NetLensCallRedactor {
  const NetLensCallRedactor(this.redaction);

  final NetLensRedaction redaction;

  /// Returns a copy of [call] with sensitive headers, cookies, query
  /// parameters, body fields and form fields replaced by the mask.
  NetLensHttpCall redact(NetLensHttpCall call) {
    if (redaction.isEmpty) {
      return call;
    }
    final NetLensHttpCall copy = call.copy()..uri = redactUrl(call.uri);
    final NetLensHttpRequest? request = copy.request;
    if (request != null) {
      request
        ..headers = redactHeaders(request.headers)
        ..cookies = _redactCookies(request.cookies)
        ..queryParameters = _redactQueryParameters(request.queryParameters)
        ..body = redactBody(request.body)
        ..formDataFields =
            request.formDataFields
                ?.map(
                  (NetLensFormDataField field) =>
                      redaction.isSensitiveBodyField(field.name)
                          ? NetLensFormDataField(field.name, redaction.mask)
                          : field,
                )
                .toList();
    }
    final NetLensHttpResponse? response = copy.response;
    if (response != null) {
      final Map<String, String>? headers = response.headers;
      response
        ..headers = headers == null ? null : redactHeaders(headers)
        ..body = redactBody(response.body);
    }
    return copy;
  }

  /// Returns [headers] with sensitive values replaced by the mask.
  Map<String, String> redactHeaders(Map<String, String> headers) => {
    for (final MapEntry<String, String> header in headers.entries)
      header.key:
          redaction.isSensitiveHeader(header.key)
              ? redaction.mask
              : header.value,
  };

  /// Returns [url] with sensitive query parameter values replaced by the
  /// mask. A URL which can't be parsed is returned unchanged.
  String redactUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasQuery || redaction.queryParameters.isEmpty) {
      return url;
    }
    final Map<String, List<String>> parameters = uri.queryParametersAll;
    if (!parameters.keys.any(redaction.isSensitiveQueryParameter)) {
      return url;
    }
    return uri
        .replace(
          queryParameters: {
            for (final MapEntry<String, List<String>> parameter
                in parameters.entries)
              parameter.key:
                  redaction.isSensitiveQueryParameter(parameter.key)
                      ? [redaction.mask]
                      : parameter.value,
          },
        )
        .toString();
  }

  /// Returns [body] with sensitive fields replaced by the mask. Maps and lists
  /// are redacted at any depth. A string is redacted when it holds JSON; other
  /// bodies are returned unchanged.
  dynamic redactBody(dynamic body) {
    if (redaction.bodyFields.isEmpty) {
      return body;
    }
    if (body is Map || body is List) {
      return _redactJson(body);
    }
    if (body is String) {
      final String trimmed = body.trimLeft();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        return body;
      }
      try {
        final dynamic decoded = jsonDecode(body);
        if (!_hasSensitiveField(decoded)) {
          return body;
        }
        return jsonEncode(_redactJson(decoded));
      } on FormatException {
        return body;
      }
    }
    return body;
  }

  dynamic _redactJson(dynamic value) {
    if (value is Map) {
      return {
        for (final MapEntry<dynamic, dynamic> entry in value.entries)
          entry.key:
              redaction.isSensitiveBodyField('${entry.key}')
                  ? redaction.mask
                  : _redactJson(entry.value),
      };
    }
    if (value is List) {
      return value.map(_redactJson).toList();
    }
    return value;
  }

  bool _hasSensitiveField(dynamic value) {
    if (value is Map) {
      return value.entries.any(
        (MapEntry<dynamic, dynamic> entry) =>
            redaction.isSensitiveBodyField('${entry.key}') ||
            _hasSensitiveField(entry.value),
      );
    }
    if (value is List) {
      return value.any(_hasSensitiveField);
    }
    return false;
  }

  Map<String, dynamic> _redactQueryParameters(Map<String, dynamic> values) => {
    for (final MapEntry<String, dynamic> entry in values.entries)
      entry.key:
          redaction.isSensitiveQueryParameter(entry.key)
              ? redaction.mask
              : entry.value,
  };

  List<Cookie> _redactCookies(List<Cookie> cookies) {
    if (!redaction.isSensitiveHeader('cookie')) {
      return cookies;
    }
    return cookies.map((Cookie cookie) {
      try {
        return Cookie(cookie.name, redaction.mask);
      } catch (_) {
        // The mask isn't a valid cookie value, so the value is dropped.
        return Cookie(cookie.name, '');
      }
    }).toList();
  }
}
