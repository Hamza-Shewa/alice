import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:flutter_test/flutter_test.dart';

NetLensHttpCall _call(dynamic body, {int status = 200}) =>
    NetLensHttpCall(1)
      ..loading = false
      ..uri = 'https://a.com/b'
      ..server = 'a.com'
      ..endpoint = '/b'
      ..secure = true
      ..response =
          (NetLensHttpResponse()
            ..status = status
            ..body = body);

void main() {
  final NetLensWatcher watcher = NetLensWatcher.instance;

  setUp(() {
    watcher.reset();
  });

  group('NetLensWatcher', () {
    test('watches the type field by default and uses it as status', () {
      expect(watcher.fields.single.path, 'type');
      expect(watcher.fields.single.values.map((v) => v.value), ['1', '2', '3']);
      expect(watcher.fields.single.useAsStatus, isTrue);
      expect(
        watcher.evaluate(_call({'type': 2}))?.outcome,
        NetLensWatchOutcome.failed,
      );
    });

    test('matches values of a field used as status', () {
      expect(
        watcher.evaluate(_call({'content': 'x', 'type': 1}))?.outcome,
        NetLensWatchOutcome.success,
      );
      final NetLensWatchResult? failed = watcher.evaluate(_call({'type': 2}));
      expect(failed?.outcome, NetLensWatchOutcome.failed);
      expect(failed?.meaning, 'Validation or business error');
      expect(
        watcher.evaluate(_call({'type': 3}))?.outcome,
        NetLensWatchOutcome.serverDown,
      );
    });

    test('reads JSON strings, numbers as text and nested paths', () {
      watcher.fields
        ..clear()
        ..add(
          NetLensWatchedField(
            path: 'data.status',
            useAsStatus: true,
            values: [
              NetLensWatchedValue(
                value: 'ERR',
                outcome: NetLensWatchOutcome.failed,
              ),
              NetLensWatchedValue(
                value: '2',
                outcome: NetLensWatchOutcome.failed,
              ),
            ],
          ),
        );
      watcher.changed();

      expect(
        watcher.evaluate(_call('{"data": {"status": "err"}}'))?.outcome,
        NetLensWatchOutcome.failed,
      );
      expect(
        watcher
            .evaluate(
              _call({
                'data': {'status': 2.0},
              }),
            )
            ?.value,
        '2',
      );
    });

    test('ignores unknown values, missing fields and non JSON', () {
      expect(watcher.evaluate(_call({'type': 'user'})), isNull);
      expect(watcher.evaluate(_call({'other': 1})), isNull);
      expect(watcher.evaluate(_call('plain text')), isNull);
      expect(watcher.evaluate(_call(null)), isNull);
    });

    test('results follow changes of the fields', () {
      final NetLensHttpCall call = _call({'type': 2});
      expect(watcher.evaluate(call)?.outcome, NetLensWatchOutcome.failed);

      watcher.fields.single.values[1].outcome = NetLensWatchOutcome.serverDown;
      watcher.changed();
      expect(watcher.evaluate(call)?.outcome, NetLensWatchOutcome.serverDown);
    });

    test('survives a JSON round trip', () {
      final NetLensWatchedField field = NetLensWatcher.defaultFields().single;
      final NetLensWatchedField copy = NetLensWatchedField.fromJson(
        field.toJson(),
      );
      expect(copy.path, 'type');
      expect(copy.useAsStatus, isTrue);
      expect(copy.values[2].outcome, NetLensWatchOutcome.serverDown);
      expect(copy.values[1].meaning, 'Validation or business error');
    });
  });

  group('NetLensIssueAnalyzer with watcher', () {
    test('HTTP 200 with a failed type is a frontend issue', () {
      final NetLensIssue? failed = NetLensIssueAnalyzer.analyze(
        _call({'type': 2}),
      );
      expect(failed?.origin, NetLensIssueOrigin.frontend);
      expect(failed?.details, 'type = 2 (Validation or business error)');

      expect(
        NetLensIssueAnalyzer.analyze(_call({'type': 3}))?.origin,
        NetLensIssueOrigin.backend,
      );
      expect(NetLensIssueAnalyzer.analyze(_call({'type': 1})), isNull);
    });

    test('is ignored while the field is not used as status', () {
      watcher.fields.single.useAsStatus = false;
      watcher.changed();
      expect(NetLensIssueAnalyzer.analyze(_call({'type': 3})), isNull);
    });

    test('real HTTP errors win', () {
      expect(
        NetLensIssueAnalyzer.analyze(_call({'type': 1}, status: 500))?.origin,
        NetLensIssueOrigin.backend,
      );
    });
  });
}
