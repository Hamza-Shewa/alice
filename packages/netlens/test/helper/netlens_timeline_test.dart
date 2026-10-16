import 'package:netlens/helper/netlens_timeline.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:test/test.dart';

NetLensHttpCall _call(
  int id,
  int startMs,
  int duration, {
  bool loading = false,
}) =>
    NetLensHttpCall(id)
      ..loading = loading
      ..duration = duration
      ..request =
          (NetLensHttpRequest()
            ..time = DateTime(2026).add(Duration(milliseconds: startMs)));

void main() {
  group('NetLensTimeline', () {
    test('lays out calls from the first start', () {
      final NetLensTimeline timeline = NetLensTimeline.from([
        _call(2, 100, 300),
        _call(1, 0, 150),
        _call(3, 500, 100),
      ]);

      expect(timeline.start, DateTime(2026));
      expect(timeline.spans.map((span) => span.call.id), [1, 2, 3]);
      expect(timeline.spans.map((span) => span.start), [0, 100, 500]);
      expect(timeline.length, 600);
      expect(timeline.maxConcurrency, 2);
    });

    test('running calls last until now', () {
      final NetLensTimeline timeline = NetLensTimeline.from([
        _call(1, 0, 0, loading: true),
      ], now: DateTime(2026).add(const Duration(seconds: 2)));
      expect(timeline.spans.single.duration, 2000);
      expect(timeline.maxConcurrency, 1);
    });

    test('keeps the latest calls only', () {
      final NetLensTimeline timeline = NetLensTimeline.from([
        for (int i = 0; i < 10; i++) _call(i, i * 10, 5),
      ], maxCalls: 3);
      expect(timeline.spans.map((span) => span.call.id), [7, 8, 9]);
      expect(timeline.spans.first.start, 0);
    });

    test('back to back calls do not overlap', () {
      expect(
        NetLensTimeline.from([
          _call(1, 0, 100),
          _call(2, 100, 100),
        ]).maxConcurrency,
        1,
      );
      expect(NetLensTimeline.from([]).spans, isEmpty);
    });
  });
}
