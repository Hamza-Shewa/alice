import 'package:netlens/model/netlens_http_call.dart';

/// Position of one call on the timeline.
class NetLensTimelineSpan {
  const NetLensTimelineSpan({
    required this.call,
    required this.start,
    required this.duration,
  });

  final NetLensHttpCall call;

  /// Milliseconds from the start of the timeline to the start of the call.
  final int start;

  /// Duration of the call in milliseconds. Calls which are still running last
  /// until the end of the timeline.
  final int duration;

  /// Milliseconds from the start of the timeline to the end of the call.
  int get end => start + duration;
}

/// Calls laid out on a time axis (waterfall), oldest first, so calls which
/// run at the same time can be seen.
class NetLensTimeline {
  const NetLensTimeline({
    required this.start,
    required this.length,
    required this.spans,
    required this.maxConcurrency,
  });

  /// Timeline of the latest [maxCalls] of [calls]. [now] is the end of calls
  /// which are still running.
  factory NetLensTimeline.from(
    List<NetLensHttpCall> calls, {
    int maxCalls = 100,
    DateTime? now,
  }) {
    final DateTime end = now ?? DateTime.now();
    final List<NetLensHttpCall> sorted = [...calls]
      ..sort((a, b) => _startOf(a).compareTo(_startOf(b)));
    final List<NetLensHttpCall> latest =
        sorted.length > maxCalls
            ? sorted.sublist(sorted.length - maxCalls)
            : sorted;
    if (latest.isEmpty) {
      return NetLensTimeline(
        start: end,
        length: 0,
        spans: const [],
        maxConcurrency: 0,
      );
    }

    final DateTime start = _startOf(latest.first);
    final List<NetLensTimelineSpan> spans = [
      for (final NetLensHttpCall call in latest)
        NetLensTimelineSpan(
          call: call,
          start: _startOf(call).difference(start).inMilliseconds,
          duration: _durationOf(call, end),
        ),
    ];
    final int length = spans.fold(
      0,
      (int length, NetLensTimelineSpan span) =>
          span.end > length ? span.end : length,
    );
    return NetLensTimeline(
      start: start,
      length: length,
      spans: spans,
      maxConcurrency: _maxConcurrency(spans),
    );
  }

  /// Time of the first call.
  final DateTime start;

  /// Milliseconds from the start of the first call to the end of the last.
  final int length;

  /// Calls, oldest first.
  final List<NetLensTimelineSpan> spans;

  /// Largest number of calls which ran at the same time.
  final int maxConcurrency;

  static DateTime _startOf(NetLensHttpCall call) =>
      call.request?.time ?? call.createdTime;

  static int _durationOf(NetLensHttpCall call, DateTime now) {
    if (call.loading) {
      final int running = now.difference(_startOf(call)).inMilliseconds;
      return running < 0 ? 0 : running;
    }
    return call.duration < 0 ? 0 : call.duration;
  }

  /// Sweeps over starts and ends to find how many calls overlapped at most.
  static int _maxConcurrency(List<NetLensTimelineSpan> spans) {
    final List<(int, int)> events = [
      for (final NetLensTimelineSpan span in spans) ...[
        (span.start, 1),
        (span.end, -1),
      ],
    ]..sort((a, b) {
      final int byTime = a.$1.compareTo(b.$1);
      // An end and a start at the same time don't overlap.
      return byTime != 0 ? byTime : a.$2.compareTo(b.$2);
    });
    int current = 0;
    int max = 0;
    for (final (int, int) event in events) {
      current += event.$2;
      if (current > max) {
        max = current;
      }
    }
    // Calls without duration never overlap, but each still ran.
    return max == 0 && spans.isNotEmpty ? 1 : max;
  }
}
