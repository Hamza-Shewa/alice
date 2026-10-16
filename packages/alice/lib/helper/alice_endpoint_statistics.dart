import 'package:alice/helper/alice_call_filter.dart';
import 'package:alice/helper/alice_graphql.dart';
import 'package:alice/model/alice_http_call.dart';

/// Response times of one endpoint, used to find slow endpoints.
class AliceEndpointTiming {
  const AliceEndpointTiming({
    required this.method,
    required this.path,
    required this.count,
    required this.failures,
    required this.p50,
    required this.p95,
    required this.max,
  });

  /// Upper case HTTP method.
  final String method;

  /// Endpoint path where IDs are replaced by `{id}`, or the GraphQL operation.
  final String path;

  /// Number of finished calls.
  final int count;

  /// Number of finished calls which failed (no response, 4xx or 5xx).
  final int failures;

  /// Median, 95th percentile and longest duration in milliseconds.
  final int p50;
  final int p95;
  final int max;
}

/// Groups calls by endpoint and calculates their response times.
class AliceEndpointStatistics {
  AliceEndpointStatistics._();

  static final RegExp _idSegmentRegExp = RegExp(
    r'^(\d+|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}|[0-9a-fA-F]{24,})$',
  );

  /// Returns timings of endpoints of finished [calls], slowest first by 95th
  /// percentile, at most [limit] of them.
  static List<AliceEndpointTiming> slowest(
    List<AliceHttpCall> calls, {
    int limit = 5,
  }) {
    final Map<(String, String), List<AliceHttpCall>> groups = {};
    for (final AliceHttpCall call in calls) {
      if (call.loading) {
        continue;
      }
      final AliceGraphQLOperation? operation = AliceGraphQL.detect(call);
      final (String, String) key = (
        call.method.toUpperCase(),
        operation?.title ?? normalizePath(call.endpoint),
      );
      (groups[key] ??= []).add(call);
    }

    final List<AliceEndpointTiming> timings = [
      for (final MapEntry<(String, String), List<AliceHttpCall>> group
          in groups.entries)
        _buildTiming(group.key.$1, group.key.$2, group.value),
    ]..sort((a, b) {
      final int byP95 = b.p95.compareTo(a.p95);
      return byP95 != 0 ? byP95 : b.count.compareTo(a.count);
    });
    return timings.take(limit).toList();
  }

  /// Returns [path] with numeric, UUID and long hexadecimal segments replaced
  /// by `{id}`, so calls of the same endpoint are grouped together.
  static String normalizePath(String path) {
    final int queryStart = path.indexOf('?');
    final String pathOnly =
        queryStart == -1 ? path : path.substring(0, queryStart);
    return pathOnly
        .split('/')
        .map(
          (String segment) =>
              _idSegmentRegExp.hasMatch(segment) ? '{id}' : segment,
        )
        .join('/');
  }

  /// Returns the value at [percentile] (0-100) of ascending [sorted] values,
  /// using the nearest-rank method.
  static int percentile(List<int> sorted, int percentile) {
    if (sorted.isEmpty) {
      return 0;
    }
    final int rank = (percentile / 100 * sorted.length).ceil();
    return sorted[(rank - 1).clamp(0, sorted.length - 1)];
  }

  static AliceEndpointTiming _buildTiming(
    String method,
    String path,
    List<AliceHttpCall> calls,
  ) {
    final List<int> durations =
        calls.map((AliceHttpCall call) => call.duration).toList()..sort();
    final int failures =
        calls.where((AliceHttpCall call) {
          final AliceCallStatusGroup group = AliceCallStatusGroup.of(call);
          return group == AliceCallStatusGroup.clientError ||
              group == AliceCallStatusGroup.serverError ||
              group == AliceCallStatusGroup.failed;
        }).length;
    return AliceEndpointTiming(
      method: method,
      path: path,
      count: calls.length,
      failures: failures,
      p50: percentile(durations, 50),
      p95: percentile(durations, 95),
      max: durations.last,
    );
  }
}
