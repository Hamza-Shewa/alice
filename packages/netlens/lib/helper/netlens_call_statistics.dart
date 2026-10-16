import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/model/netlens_http_call.dart';

/// Numbers shown on the stats page, calculated from a list of calls.
class NetLensCallStatistics {
  const NetLensCallStatistics({
    required this.total,
    required this.pending,
    required this.success,
    required this.redirection,
    required this.error,
    required this.bytesSent,
    required this.bytesReceived,
    required this.averageTime,
    required this.maxTime,
    required this.minTime,
    required this.methods,
    required this.secured,
    required this.unsecured,
    required this.issues,
  });

  factory NetLensCallStatistics.from(List<NetLensHttpCall> calls) {
    int pending = 0;
    int success = 0;
    int redirection = 0;
    int error = 0;
    int bytesSent = 0;
    int bytesReceived = 0;
    int secured = 0;
    int durationSum = 0;
    int durationCount = 0;
    int maxTime = 0;
    int? minTime;
    final Map<String, int> methods = {};
    final Map<NetLensIssueOrigin, int> issues = {};

    for (final NetLensHttpCall call in calls) {
      final int? status = call.response?.status;
      if (call.loading) {
        pending++;
      } else if (status != null && status >= 200 && status < 300) {
        success++;
      } else if (status != null && status >= 300 && status < 400) {
        redirection++;
      } else if (status != null &&
          ((status >= 400 && status < 600) || status == -1 || status == 0)) {
        error++;
      }

      bytesSent += call.request?.size ?? 0;
      bytesReceived += call.response?.size ?? 0;
      if (call.secure) {
        secured++;
      }
      if (call.duration > 0) {
        durationSum += call.duration;
        durationCount++;
        if (call.duration > maxTime) {
          maxTime = call.duration;
        }
        if (minTime == null || call.duration < minTime) {
          minTime = call.duration;
        }
      }
      final String method = call.method.toUpperCase();
      methods[method] = (methods[method] ?? 0) + 1;

      final NetLensIssue? issue = NetLensIssueAnalyzer.analyze(call);
      if (issue != null) {
        issues[issue.origin] = (issues[issue.origin] ?? 0) + 1;
      }
    }

    return NetLensCallStatistics(
      total: calls.length,
      pending: pending,
      success: success,
      redirection: redirection,
      error: error,
      bytesSent: bytesSent,
      bytesReceived: bytesReceived,
      averageTime: durationCount == 0 ? 0 : durationSum ~/ durationCount,
      maxTime: maxTime,
      minTime: minTime ?? 0,
      methods: methods,
      secured: secured,
      unsecured: calls.length - secured,
      issues: issues,
    );
  }

  final int total;
  final int pending;
  final int success;
  final int redirection;
  final int error;
  final int bytesSent;
  final int bytesReceived;

  /// Average, longest and shortest duration in milliseconds, of the calls
  /// which have a duration.
  final int averageTime;
  final int maxTime;
  final int minTime;

  /// Number of calls per HTTP method.
  final Map<String, int> methods;
  final int secured;
  final int unsecured;

  /// Number of failed calls per side responsible for the failure.
  final Map<NetLensIssueOrigin, int> issues;

  /// Number of calls which failed for any reason.
  int get issueCount =>
      issues.values.fold(0, (int sum, int count) => sum + count);

  /// Percentage (0-100) of finished calls which succeeded, or null when no
  /// call has finished.
  int? get successRate {
    final int finished = total - pending;
    return finished == 0 ? null : (success * 100 / finished).round();
  }
}
