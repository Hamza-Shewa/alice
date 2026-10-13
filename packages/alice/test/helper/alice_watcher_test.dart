import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call(dynamic body, {int status = 200}) =>
    AliceHttpCall(1)
      ..loading = false
      ..uri = 'https://a.com/b'
      ..server = 'a.com'
      ..endpoint = '/b'
      ..secure = true
      ..response =
          (AliceHttpResponse()
            ..status = status
            ..body = body);

void main() {
  final AliceWatcher watcher = AliceWatcher.instance;

  setUp(() {
    watcher.reset();
  });

  group('AliceWatcher', () {
    test('watches the type field by default and uses it as status', () {
      expect(watcher.fields.single.path, 'type');
      expect(watcher.fields.single.values.map((v) => v.value), ['1', '2', '3']);
      expect(watcher.fields.single.useAsStatus, isTrue);
      expect(
        watcher.evaluate(_call({'type': 2}))?.outcome,
        AliceWatchOutcome.failed,
      );
    });

    test('matches values of a field used as status', () {
      expect(
        watcher.evaluate(_call({'content': 'x', 'type': 1}))?.outcome,
        AliceWatchOutcome.success,
      );
      final AliceWatchResult? failed = watcher.evaluate(_call({'type': 2}));
      expect(failed?.outcome, AliceWatchOutcome.failed);
      expect(failed?.meaning, 'Validation or business error');
      expect(
        watcher.evaluate(_call({'type': 3}))?.outcome,
        AliceWatchOutcome.serverDown,
      );
    });

    test('reads JSON strings, numbers as text and nested paths', () {
      watcher.fields
        ..clear()
        ..add(
          AliceWatchedField(
            path: 'data.status',
            useAsStatus: true,
            values: [
              AliceWatchedValue(
                value: 'ERR',
                outcome: AliceWatchOutcome.failed,
              ),
              AliceWatchedValue(value: '2', outcome: AliceWatchOutcome.failed),
            ],
          ),
        );
      watcher.changed();

      expect(
        watcher.evaluate(_call('{"data": {"status": "err"}}'))?.outcome,
        AliceWatchOutcome.failed,
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
      final AliceHttpCall call = _call({'type': 2});
      expect(watcher.evaluate(call)?.outcome, AliceWatchOutcome.failed);

      watcher.fields.single.values[1].outcome = AliceWatchOutcome.serverDown;
      watcher.changed();
      expect(watcher.evaluate(call)?.outcome, AliceWatchOutcome.serverDown);
    });

    test('survives a JSON round trip', () {
      final AliceWatchedField field = AliceWatcher.defaultFields().single;
      final AliceWatchedField copy = AliceWatchedField.fromJson(field.toJson());
      expect(copy.path, 'type');
      expect(copy.useAsStatus, isTrue);
      expect(copy.values[2].outcome, AliceWatchOutcome.serverDown);
      expect(copy.values[1].meaning, 'Validation or business error');
    });
  });

  group('AliceIssueAnalyzer with watcher', () {
    test('HTTP 200 with a failed type is a frontend issue', () {
      final AliceIssue? failed = AliceIssueAnalyzer.analyze(_call({'type': 2}));
      expect(failed?.origin, AliceIssueOrigin.frontend);
      expect(failed?.details, 'type = 2 (Validation or business error)');

      expect(
        AliceIssueAnalyzer.analyze(_call({'type': 3}))?.origin,
        AliceIssueOrigin.backend,
      );
      expect(AliceIssueAnalyzer.analyze(_call({'type': 1})), isNull);
    });

    test('is ignored while the field is not used as status', () {
      watcher.fields.single.useAsStatus = false;
      watcher.changed();
      expect(AliceIssueAnalyzer.analyze(_call({'type': 3})), isNull);
    });

    test('real HTTP errors win', () {
      expect(
        AliceIssueAnalyzer.analyze(_call({'type': 1}, status: 500))?.origin,
        AliceIssueOrigin.backend,
      );
    });
  });
}
