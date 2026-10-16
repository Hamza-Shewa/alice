import 'dart:convert' show jsonEncode;

import 'package:alice/model/alice_http_call.dart';
import 'package:equatable/equatable.dart';

/// Request which is sent again by an [AliceCallReplayer]. It is built from a
/// caught call and can be edited before it is sent.
class AliceReplayRequest with Equatable {
  const AliceReplayRequest({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.omitsFormData = false,
  });

  /// Headers which are set by the HTTP client itself and must not be copied,
  /// because they wouldn't match the new request.
  static const Set<String> _clientHeaders = {'content-length', 'host'};

  /// Builds a request with the method, URL, headers and body of [call].
  factory AliceReplayRequest.fromCall(AliceHttpCall call) {
    final Map<String, String> headers = {
      for (final MapEntry<String, String> header
          in call.request?.headers.entries ?? <MapEntry<String, String>>[])
        if (!_clientHeaders.contains(header.key.toLowerCase()))
          header.key: header.value,
    };
    final bool hasFormData =
        (call.request?.formDataFields?.isNotEmpty ?? false) ||
        (call.request?.formDataFiles?.isNotEmpty ?? false);
    return AliceReplayRequest(
      method: call.method.toUpperCase(),
      url: _getUrl(call),
      headers: headers,
      // Alice keeps only names and sizes of form data, so it can't be sent.
      body: hasFormData ? null : encodeBody(call.request?.body),
      omitsFormData: hasFormData,
    );
  }

  /// HTTP method, for example GET.
  final String method;

  /// Full URL with query parameters.
  final String url;

  final Map<String, String> headers;

  /// Body as text, or null when the request has no body.
  final String? body;

  /// True when the original call sent form data, which can't be sent again.
  final bool omitsFormData;

  /// Returns true when the request has a body.
  bool get hasBody => body != null && body!.isNotEmpty;

  /// Returns [headers] as text with one `Name: value` line per header.
  static String headersToText(Map<String, String> headers) => headers.entries
      .map(
        (MapEntry<String, String> header) => '${header.key}: ${header.value}',
      )
      .join('\n');

  /// Parses [text] with one `Name: value` line per header. Empty lines are
  /// skipped. Returns the headers, or the 1-based number of the first line
  /// which isn't a header.
  static ({Map<String, String> headers, int? invalidLine}) parseHeaders(
    String text,
  ) {
    final Map<String, String> headers = {};
    final List<String> lines = text.split('\n');
    for (int index = 0; index < lines.length; index++) {
      final String line = lines[index].trim();
      if (line.isEmpty) {
        continue;
      }
      final int separator = line.indexOf(':');
      final String name =
          separator > 0 ? line.substring(0, separator).trim() : '';
      if (name.isEmpty || name.contains(' ')) {
        return (headers: headers, invalidLine: index + 1);
      }
      headers[name] = line.substring(separator + 1).trim();
    }
    return (headers: headers, invalidLine: null);
  }

  /// Returns [body] as text: maps and lists are encoded as JSON, an empty body
  /// is null.
  static String? encodeBody(dynamic body) {
    if (body == null) {
      return null;
    }
    if (body is Map || body is List) {
      try {
        return jsonEncode(body);
      } catch (_) {
        return body.toString();
      }
    }
    final String text = body.toString();
    return text.isEmpty ? null : text;
  }

  static String _getUrl(AliceHttpCall call) {
    if (call.uri.isNotEmpty) {
      return call.uri;
    }
    final Map<String, dynamic> query =
        call.request?.queryParameters ?? const {};
    final String scheme = call.secure ? 'https' : 'http';
    return Uri.parse('$scheme://${call.server}${call.endpoint}')
        .replace(
          queryParameters:
              query.isEmpty
                  ? null
                  : query.map(
                    (String key, dynamic value) => MapEntry(key, '$value'),
                  ),
        )
        .toString();
  }

  AliceReplayRequest copyWith({
    String? method,
    String? url,
    Map<String, String>? headers,
    String? body,
  }) => AliceReplayRequest(
    method: method ?? this.method,
    url: url ?? this.url,
    headers: headers ?? this.headers,
    body: body ?? this.body,
    omitsFormData: omitsFormData,
  );

  @override
  List<Object?> get props => [method, url, headers, body, omitsFormData];
}
