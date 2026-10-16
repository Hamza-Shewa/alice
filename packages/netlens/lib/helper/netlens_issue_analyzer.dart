import 'package:netlens/helper/netlens_url_validator.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';

/// Side which most likely caused a failed call.
enum NetLensIssueOrigin {
  /// The app sent a wrong request or failed to handle the response.
  frontend,

  /// The backend failed or is unavailable.
  backend,

  /// The request or the response got lost on the way.
  network,
}

/// Result of call analysis: who is probably responsible and why.
class NetLensIssue {
  const NetLensIssue({
    required this.origin,
    required this.reason,
    this.details,
  });

  final NetLensIssueOrigin origin;

  /// Translation key of the explanation. It may contain `[status]` and
  /// `[error]` placeholders, which are replaced with [details].
  final NetLensTranslationKey reason;

  /// Value which replaces placeholders in the reason: status code or error.
  final String? details;
}

/// Decides whether a failed call is a frontend, backend or network issue,
/// based on the response status, the error and the request URL.
class NetLensIssueAnalyzer {
  NetLensIssueAnalyzer._();

  static final RegExp _networkErrorRegExp = RegExp(
    r'time ?out|timed out|socket|connection (?:refused|closed|reset|error|'
    r'failed)|network|host lookup|dns|handshake|certificate|unreachable|'
    r'no route|connect(?:ion)? took longer|failed to connect',
    caseSensitive: false,
  );

  /// Returns the issue found in [call] or null when the call succeeded or is
  /// still running.
  static NetLensIssue? analyze(NetLensHttpCall call) {
    if (call.loading) {
      return null;
    }

    final int? status = call.response?.status;
    final String? error = call.error?.error?.toString();
    // -1 or 0 are used when the call failed without a valid response.
    final bool hasNoResponse = status == null || status < 100;
    final bool isClientError = status != null && status >= 400 && status < 500;

    // A URL which looks wrong explains only a call which didn't reach the
    // endpoint. A call which got a successful response reached it, so the
    // URL heuristics must not turn it into a failure.
    if ((hasNoResponse || isClientError) &&
        NetLensUrlValidator.validateCall(call).isNotEmpty) {
      return const NetLensIssue(
        origin: NetLensIssueOrigin.frontend,
        reason: NetLensTranslationKey.issueReasonMalformedUrl,
      );
    }

    if (status != null && status >= 500 && status < 600) {
      return NetLensIssue(
        origin: NetLensIssueOrigin.backend,
        reason:
            const [502, 503, 504].contains(status)
                ? NetLensTranslationKey.issueReasonGateway
                : NetLensTranslationKey.issueReasonServerError,
        details: '$status',
      );
    }
    if (status != null && status >= 400 && status < 500) {
      return _analyzeClientError(status);
    }
    if (hasNoResponse) {
      if (error != null && !_networkErrorRegExp.hasMatch(error)) {
        return NetLensIssue(
          origin: NetLensIssueOrigin.frontend,
          reason: NetLensTranslationKey.issueReasonAppError,
          details: _shorten(error),
        );
      }
      return NetLensIssue(
        origin: NetLensIssueOrigin.network,
        reason: NetLensTranslationKey.issueReasonNetwork,
        details: error == null ? null : _shorten(error),
      );
    }
    final NetLensWatchResult? watch = NetLensWatcher.instance.evaluate(call);
    if (watch != null && watch.outcome != NetLensWatchOutcome.success) {
      // The HTTP status is fine, but the watched field reports a failure.
      return NetLensIssue(
        origin:
            watch.outcome == NetLensWatchOutcome.serverDown
                ? NetLensIssueOrigin.backend
                : NetLensIssueOrigin.frontend,
        reason:
            watch.outcome == NetLensWatchOutcome.serverDown
                ? NetLensTranslationKey.issueReasonWatchServerDown
                : NetLensTranslationKey.issueReasonWatchFailed,
        details:
            '${watch.path} = ${watch.value}'
            '${watch.meaning.isEmpty ? '' : ' (${watch.meaning})'}',
      );
    }
    if (error != null) {
      // The response is fine, so the app failed while handling it.
      return NetLensIssue(
        origin: NetLensIssueOrigin.frontend,
        reason: NetLensTranslationKey.issueReasonAppError,
        details: _shorten(error),
      );
    }
    return null;
  }

  /// Returns the origin of an HTTP [status] code, or null when it isn't an
  /// error status. Used for logs, which only contain a status code.
  static NetLensIssueOrigin? originForStatus(int status) {
    if (status >= 500 && status < 600) {
      return NetLensIssueOrigin.backend;
    }
    if (status == 408) {
      return NetLensIssueOrigin.network;
    }
    if (status >= 400 && status < 500) {
      return NetLensIssueOrigin.frontend;
    }
    return null;
  }

  static NetLensIssue _analyzeClientError(int status) {
    final NetLensTranslationKey reason = switch (status) {
      401 || 403 => NetLensTranslationKey.issueReasonAuth,
      404 => NetLensTranslationKey.issueReasonNotFound,
      _ => NetLensTranslationKey.issueReasonClientError,
    };
    return NetLensIssue(
      origin: originForStatus(status)!,
      reason: status == 408 ? NetLensTranslationKey.issueReasonNetwork : reason,
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
