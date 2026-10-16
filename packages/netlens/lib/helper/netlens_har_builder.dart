import 'dart:convert' show jsonEncode;
import 'dart:io' show Cookie;

import 'package:netlens/core/netlens_http_status.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:netlens/utils/netlens_parser.dart';

/// Builds HTTP Archive (HAR 1.2) documents from calls. HAR files open in
/// browser developer tools and in proxies such as Proxyman or Charles.
///
/// See http://www.softwareishard.com/blog/har-12-spec/.
class NetLensHarBuilder {
  static const String _version = '1.2';
  static const String _creatorName = 'NetLens';
  static const String _httpVersion = 'HTTP/1.1';
  static const String _defaultMimeType = 'application/octet-stream';

  /// Returns HAR document with one entry per call in [calls], sorted by start
  /// time.
  static Map<String, dynamic> build(
    List<NetLensHttpCall> calls, {
    String creatorVersion = '',
  }) {
    final List<NetLensHttpCall> sorted = [...calls]
      ..sort((a, b) => _startTime(a).compareTo(_startTime(b)));
    return {
      'log': {
        'version': _version,
        'creator': {'name': _creatorName, 'version': creatorVersion},
        'pages': <dynamic>[],
        'entries': sorted.map(buildEntry).toList(),
      },
    };
  }

  /// Returns HAR document of [calls] encoded as JSON.
  static String encode(
    List<NetLensHttpCall> calls, {
    String creatorVersion = '',
  }) => jsonEncode(build(calls, creatorVersion: creatorVersion));

  /// Returns HAR entry of [call].
  static Map<String, dynamic> buildEntry(NetLensHttpCall call) {
    final int duration = call.duration < 0 ? 0 : call.duration;
    return {
      'startedDateTime': _startTime(call).toUtc().toIso8601String(),
      'time': duration,
      'request': _buildRequest(call),
      'response': _buildResponse(call),
      'cache': <String, dynamic>{},
      'timings': {'send': 0, 'wait': duration, 'receive': 0},
      if (call.error?.error != null) 'comment': '${call.error!.error}',
    };
  }

  static DateTime _startTime(NetLensHttpCall call) =>
      call.request?.time ?? call.createdTime;

  static Map<String, dynamic> _buildRequest(NetLensHttpCall call) {
    final NetLensHttpRequest? request = call.request;
    final String url = NetLensReplayRequest.fromCall(call).url;
    final String? body = NetLensReplayRequest.encodeBody(request?.body);
    final String? contentType =
        (request?.contentType?.trim().isNotEmpty ?? false)
            ? request!.contentType
            : NetLensParser.tryGetContentType(request?.headers);
    return {
      'method': call.method.toUpperCase(),
      'url': url,
      'httpVersion': _httpVersion,
      'cookies': _buildCookies(request?.cookies ?? const []),
      'headers': _buildHeaders(request?.headers),
      'queryString': _buildQueryString(url),
      if (body != null)
        'postData': {
          'mimeType': contentType ?? _defaultMimeType,
          'text': body,
          if (request?.formDataFields?.isNotEmpty ?? false)
            'params': [
              for (final field in request!.formDataFields!)
                {'name': field.name, 'value': field.value},
            ],
        },
      'headersSize': -1,
      'bodySize': request?.size ?? 0,
    };
  }

  static Map<String, dynamic> _buildResponse(NetLensHttpCall call) {
    final NetLensHttpResponse? response = call.loading ? null : call.response;
    final int status = response?.status ?? 0;
    final int harStatus = status < 0 ? 0 : status;
    final String? text = NetLensReplayRequest.encodeBody(response?.body);
    return {
      'status': harStatus,
      'statusText':
          NetLensHttpStatus.get(status: harStatus, languageCode: 'en')?.name ??
          '',
      'httpVersion': _httpVersion,
      'cookies': <dynamic>[],
      'headers': _buildHeaders(response?.headers),
      'content': {
        'size': response?.size ?? 0,
        'mimeType':
            NetLensParser.tryGetContentType(response?.headers) ??
            _defaultMimeType,
        if (text != null) 'text': text,
      },
      'redirectURL': _getHeader(response?.headers, 'location') ?? '',
      'headersSize': -1,
      'bodySize': response?.size ?? -1,
    };
  }

  static List<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
  ) => [
    for (final MapEntry<String, String> header
        in headers?.entries ?? <MapEntry<String, String>>[])
      {'name': header.key, 'value': header.value},
  ];

  static List<Map<String, dynamic>> _buildCookies(List<Cookie> cookies) => [
    for (final Cookie cookie in cookies)
      {'name': cookie.name, 'value': cookie.value},
  ];

  static List<Map<String, String>> _buildQueryString(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return const [];
    }
    return [
      for (final MapEntry<String, List<String>> parameter
          in uri.queryParametersAll.entries)
        for (final String value in parameter.value)
          {'name': parameter.key, 'value': value},
    ];
  }

  static String? _getHeader(Map<String, String>? headers, String name) {
    for (final MapEntry<String, String> header
        in headers?.entries ?? <MapEntry<String, String>>[]) {
      if (header.key.toLowerCase() == name) {
        return header.value;
      }
    }
    return null;
  }
}
