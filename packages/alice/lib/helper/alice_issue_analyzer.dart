import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';

/// Side which most likely caused a failed call.
enum AliceIssueOrigin {
  /// The app sent a wrong request or failed to handle the response.
  frontend,

  /// The backend failed or is unavailable.
  backend,

  /// The request or the response got lost on the way.
  network,
}

/// Result of call analysis: who is probably responsible and why.
class AliceIssue {
  const AliceIssue({required this.origin, required this.reason, this.details});

  final AliceIssueOrigin origin;

  /// Translation key of the explanation. It may contain `[status]` and
  /// `[error]` placeholders, which are replaced with [details].
  final AliceTranslationKey reason;

  /// Value which replaces placeholders in the reason: status code or error.
  final String? details;
}

/// Decides whether a failed call is a frontend, backend or network issue,
/// based on the response status, the error and the request URL.
class AliceIssueAnalyzer {
  AliceIssueAnalyzer._();

  static final RegExp _networkErrorRegExp = RegExp(
    r'time ?out|timed out|socket|connection (?:refused|closed|reset|error|'
    r'failed)|network|host lookup|dns|handshake|certificate|unreachable|'
    r'no route|connect(?:ion)? took longer|failed to connect',
    caseSensitive: false,
  );

  /// Returns the issue found in [call] or null when the call succeeded or is
  /// still running.
  static AliceIssue? analyze(AliceHttpCall call) {
    if (call.loading) {
      return null;
    }
    if (AliceUrlValidator.validateCall(call).isNotEmpty) {
      return const AliceIssue(
        origin: AliceIssueOrigin.frontend,
        reason: AliceTranslationKey.issueReasonMalformedUrl,
      );
    }

    final int? status = call.response?.status;
    final String? error = call.error?.error?.toString();

    if (status != null && status >= 500 && status < 600) {
      return AliceIssue(
        origin: AliceIssueOrigin.backend,
        reason:
            const [502, 503, 504].contains(status)
                ? AliceTranslationKey.issueReasonGateway
                : AliceTranslationKey.issueReasonServerError,
        details: '$status',
      );
    }
    if (status != null && status >= 400 && status < 500) {
      return _analyzeClientError(status);
    }
    if (status == null || status < 100) {
      // No valid response: -1 or 0 are used when the call failed.
      if (error != null && !_networkErrorRegExp.hasMatch(error)) {
        return AliceIssue(
          origin: AliceIssueOrigin.frontend,
          reason: AliceTranslationKey.issueReasonAppError,
          details: _shorten(error),
        );
      }
      return AliceIssue(
        origin: AliceIssueOrigin.network,
        reason: AliceTranslationKey.issueReasonNetwork,
        details: error == null ? null : _shorten(error),
      );
    }
    final AliceWatchResult? watch = AliceWatcher.instance.evaluate(call);
    if (watch != null && watch.outcome != AliceWatchOutcome.success) {
      // The HTTP status is fine, but the watched field reports a failure.
      return AliceIssue(
        origin:
            watch.outcome == AliceWatchOutcome.serverDown
                ? AliceIssueOrigin.backend
                : AliceIssueOrigin.frontend,
        reason:
            watch.outcome == AliceWatchOutcome.serverDown
                ? AliceTranslationKey.issueReasonWatchServerDown
                : AliceTranslationKey.issueReasonWatchFailed,
        details:
            '${watch.path} = ${watch.value}'
            '${watch.meaning.isEmpty ? '' : ' (${watch.meaning})'}',
      );
    }
    if (error != null) {
      // The response is fine, so the app failed while handling it.
      return AliceIssue(
        origin: AliceIssueOrigin.frontend,
        reason: AliceTranslationKey.issueReasonAppError,
        details: _shorten(error),
      );
    }
    return null;
  }

  /// Returns the origin of an HTTP [status] code, or null when it isn't an
  /// error status. Used for logs, which only contain a status code.
  static AliceIssueOrigin? originForStatus(int status) {
    if (status >= 500 && status < 600) {
      return AliceIssueOrigin.backend;
    }
    if (status == 408) {
      return AliceIssueOrigin.network;
    }
    if (status >= 400 && status < 500) {
      return AliceIssueOrigin.frontend;
    }
    return null;
  }

  static AliceIssue _analyzeClientError(int status) {
    final AliceTranslationKey reason = switch (status) {
      401 || 403 => AliceTranslationKey.issueReasonAuth,
      404 => AliceTranslationKey.issueReasonNotFound,
      _ => AliceTranslationKey.issueReasonClientError,
    };
    return AliceIssue(
      origin: originForStatus(status)!,
      reason: status == 408 ? AliceTranslationKey.issueReasonNetwork : reason,
      details: status == 408 ? 'HTTP 408' : '$status',
    );
  }

  /// Returns first line of [error], which is enough to explain the problem.
  static String _shorten(String error) {
    final String firstLine = error.trim().split('\n').first.trim();
    return firstLine.length > 160
        ? '${firstLine.substring(0, 160)}…'
        : firstLine;
  }
}
