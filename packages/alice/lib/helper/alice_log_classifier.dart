import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/model/alice_log.dart';
import 'package:flutter/foundation.dart';

/// Kind of a log entry, detected from its message, error and level.
enum AliceLogKind { request, response, error, warning, info }

/// What was detected in a log entry.
class AliceLogInfo {
  const AliceLogInfo({
    required this.kind,
    this.method,
    this.status,
    this.url,
    this.origin,
  });

  final AliceLogKind kind;

  /// HTTP method of a request log.
  final String? method;

  /// HTTP status of a response or HTTP error log.
  final int? status;

  /// URL or path found in the message.
  final String? url;

  /// Side which caused the failure, when the log describes a failed call.
  final AliceIssueOrigin? origin;

  /// Whether the log describes an API call, successful or not.
  bool get isApiCall =>
      kind == AliceLogKind.request ||
      kind == AliceLogKind.response ||
      status != null;

  /// Whether the log describes a failure.
  bool get isFailure =>
      kind == AliceLogKind.error || (status != null && status! >= 400);
}

/// Detects API calls and errors in log entries written by HTTP loggers (Dio,
/// http, Chopper, custom ones), so the logs can be colored and filtered.
class AliceLogClassifier {
  AliceLogClassifier._();

  static const String _methods = 'GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS';

  /// `RESPONSE[200]`, `<-- 200`, `HTTP/1.1 200`, `status: 200`, `statusCode=200`.
  static final RegExp _response = RegExp(
    r'RESPONSE\s*\[\s*(\d{3})|<--\s*(\d{3})|HTTP/\d(?:\.\d)?\s+(\d{3})|'
    r'status(?:\s*code)?\s*[:=]\s*(\d{3})|\bstatusCode\b\D{0,3}(\d{3})',
    caseSensitive: false,
  );

  /// `ERROR[404]`, `DioException [bad response]`, `status code of 500`.
  static final RegExp _httpError = RegExp(
    r'ERROR\s*\[\s*(\d{3})|status code of (\d{3})',
    caseSensitive: false,
  );

  /// `REQUEST[GET]`, `--> POST`, `GET https://...`, `GET /v1/users`.
  static final RegExp _request = RegExp(
    '(?:REQUEST\\s*\\[\\s*($_methods)|-->\\s*($_methods)|'
    '\\b($_methods)\\s+(?:https?://|/))',
    caseSensitive: false,
  );

  static final RegExp _url = RegExp(r'https?://[^\s"\x27<>\]]+');
  static final RegExp _path = RegExp(
    '(?:PATH:\\s*|(?:$_methods)\\s+)(/\\S*)',
    caseSensitive: false,
  );

  static final RegExp _errorWords = RegExp(
    r'exception|\berror\b|\bfailed\b|failure|time ?out|timed out|refused|'
    r'unreachable|\bfatal\b|\bcrash',
    caseSensitive: false,
  );

  static final RegExp _networkWords = RegExp(
    r'time ?out|timed out|socket|connection|network|host lookup|dns|'
    r'handshake|certificate|unreachable',
    caseSensitive: false,
  );

  /// Classifies [log].
  static AliceLogInfo classify(AliceLog log) {
    final String text = [
      log.message,
      if (log.error != null) log.error.toString(),
    ].join('\n');

    final int? status =
        _firstGroup(_response.firstMatch(text)) ??
        _firstGroup(_httpError.firstMatch(text));
    final String? url = _findUrl(text);

    if (status != null) {
      final bool isError =
          status >= 400 ||
          _httpError.hasMatch(text) ||
          log.level.index >= DiagnosticLevel.error.index;
      return AliceLogInfo(
        kind: isError ? AliceLogKind.error : AliceLogKind.response,
        status: status,
        url: url,
        origin: AliceIssueAnalyzer.originForStatus(status),
      );
    }

    final bool isErrorLevel = log.level.index >= DiagnosticLevel.error.index;
    final bool hasErrorWords = _errorWords.hasMatch(text);
    if (isErrorLevel || log.error != null || hasErrorWords) {
      return AliceLogInfo(
        kind: AliceLogKind.error,
        url: url,
        origin: _networkWords.hasMatch(text) ? AliceIssueOrigin.network : null,
      );
    }

    final RegExpMatch? request = _request.firstMatch(text);
    if (request != null) {
      return AliceLogInfo(
        kind: AliceLogKind.request,
        method: _firstGroupText(request)?.toUpperCase(),
        url: url,
      );
    }

    if (log.level == DiagnosticLevel.warning) {
      return AliceLogInfo(kind: AliceLogKind.warning, url: url);
    }
    return AliceLogInfo(kind: AliceLogKind.info, url: url);
  }

  static int? _firstGroup(RegExpMatch? match) {
    final String? value = _firstGroupText(match);
    return value == null ? null : int.tryParse(value);
  }

  static String? _firstGroupText(RegExpMatch? match) {
    if (match == null) {
      return null;
    }
    for (int i = 1; i <= match.groupCount; i++) {
      final String? group = match.group(i);
      if (group != null) {
        return group;
      }
    }
    return null;
  }

  static String? _findUrl(String text) =>
      _url.firstMatch(text)?.group(0) ?? _path.firstMatch(text)?.group(1);
}
