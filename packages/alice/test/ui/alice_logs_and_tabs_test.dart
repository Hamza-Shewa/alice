import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/ui/call_details/widget/alice_call_request_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_response_screen.dart';
import 'package:alice/ui/calls_list/widget/alice_call_list_item_widget.dart';
import 'package:alice/ui/calls_list/widget/alice_log_list_widget.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call({int status = 200}) =>
    AliceHttpCall(1)
      ..method = 'POST'
      ..server = 'api.example.com'
      ..endpoint = '/v1/users'
      ..uri = 'https://api.example.com/v1/users?page=2'
      ..client = 'Dio'
      ..secure = true
      ..loading = false
      ..duration = 120
      ..request =
          (AliceHttpRequest()
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 37)
            ..size = 230
            ..headers = {
              'content-type': 'application/json',
              'authorization': 'Bearer abc',
            }
            ..queryParameters = {'page': 2}
            ..body = {'name': 'Ann'})
      ..response =
          (AliceHttpResponse()
            ..status = status
            ..size = 99
            ..headers = {'content-type': 'application/json'}
            ..body = '{"ok":true}'
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 157));

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

void main() {
  group('logger', () {
    final List<AliceLog> logs = [
      AliceLog(message: 'REQUEST[GET] => PATH: /v1/users'),
      AliceLog(message: 'RESPONSE[200] => PATH: /v1/users'),
      AliceLog(message: 'RESPONSE[503] => PATH: /v1/orders'),
      AliceLog(message: 'Low disk', level: DiagnosticLevel.warning),
      AliceLog(message: 'User opened the screen'),
    ];

    Future<void> pumpLogs(WidgetTester tester) => _pump(
      tester,
      AliceLogListWidget(
        logsStream: Stream.value(logs),
        initialLogs: logs,
        scrollController: ScrollController(),
      ),
    );

    testWidgets('shows kind and origin flags', (tester) async {
      await pumpLogs(tester);

      expect(find.text('REQUEST GET'), findsOneWidget);
      expect(find.text('RESPONSE 200'), findsOneWidget);
      expect(find.text('ERROR 503'), findsOneWidget);
      expect(find.text('WARNING'), findsOneWidget);
      expect(find.text('Backend issue'), findsOneWidget);
    });

    testWidgets('filters logs', (tester) async {
      await pumpLogs(tester);
      expect(find.text('User opened the screen'), findsOneWidget);

      await tester.tap(find.text('Errors 1'));
      await tester.pump();
      expect(find.text('User opened the screen'), findsNothing);
      expect(find.text('RESPONSE[503] => PATH: /v1/orders'), findsOneWidget);

      await tester.tap(find.text('Requests 1'));
      await tester.pump();
      expect(find.text('RESPONSE[503] => PATH: /v1/orders'), findsNothing);
      expect(find.text('REQUEST[GET] => PATH: /v1/users'), findsOneWidget);
    });
  });

  group('issue flag', () {
    testWidgets('list item flags backend failures', (tester) async {
      await _pump(tester, AliceCallListItemWidget(_call(status: 500), (_) {}));
      expect(find.text('Backend issue'), findsOneWidget);
    });

    testWidgets('list item flags frontend failures', (tester) async {
      await _pump(tester, AliceCallListItemWidget(_call(status: 422), (_) {}));
      expect(find.text('Frontend issue'), findsOneWidget);
    });

    testWidgets('list item has no flag for successful calls', (tester) async {
      await _pump(tester, AliceCallListItemWidget(_call(), (_) {}));
      expect(find.byIcon(Icons.flag), findsNothing);
    });

    testWidgets('request and response tabs explain the issue', (tester) async {
      await _pump(tester, AliceCallRequestScreen(call: _call(status: 500)));
      expect(find.text('Backend issue'), findsOneWidget);
      expect(find.textContaining('HTTP 500'), findsOneWidget);

      await _pump(tester, AliceCallResponseScreen(call: _call(status: 404)));
      expect(find.text('Frontend issue'), findsOneWidget);
    });
  });

  group('tabs', () {
    testWidgets('request tab shows sections', (tester) async {
      await _pump(tester, AliceCallRequestScreen(call: _call()));

      expect(find.text('Query parameters'), findsOneWidget);
      expect(find.text('Headers'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('authorization'), findsOneWidget);
      expect(find.text('Bearer abc'), findsOneWidget);
    });

    testWidgets('headers section collapses', (tester) async {
      await _pump(tester, AliceCallRequestScreen(call: _call()));
      expect(find.text('Bearer abc'), findsOneWidget);

      await tester.tap(find.text('Headers'));
      await tester.pumpAndSettle();
      expect(find.text('Bearer abc'), findsNothing);
    });

    testWidgets('response tab shows status and body', (tester) async {
      await _pump(tester, AliceCallResponseScreen(call: _call()));

      expect(find.text('200'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.textContaining('"ok"'), findsWidgets);
    });
  });

  group('scroll performance', () {
    testWidgets('detail tabs use cheap, non-editable text', (tester) async {
      tester.view.physicalSize = const Size(400, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final AliceHttpCall call = _call();
      call.request!.headers = {
        for (int i = 0; i < 8; i++) 'header-$i': 'value-$i',
      };

      for (final Widget screen in [
        AliceCallRequestScreen(call: call),
        AliceCallResponseScreen(call: call),
      ]) {
        await _pump(tester, screen);
        // SelectableText creates an EditableText each; with many headers
        // that made scrolling stutter. One SelectionArea does the job.
        expect(find.byType(EditableText), findsNothing);
        expect(find.byType(SelectionArea), findsOneWidget);
      }
    });
  });

  group('layout', () {
    final List<AliceLog> logs = [
      AliceLog(
        message: 'REQUEST[GET] => PATH: /v1/users/with/a/very/long/path',
      ),
      AliceLog(message: 'RESPONSE[503] => PATH: /v1/orders ${'x' * 600}'),
      AliceLog(
        message: 'Login failed',
        level: DiagnosticLevel.error,
        error: Exception('boom'),
        stackTrace: StackTrace.fromString('#0 main (file.dart:1:1)'),
      ),
    ];

    for (final bool dark in [false, true]) {
      for (final String language in ['en', 'ar']) {
        testWidgets('screens fit a narrow phone (dark=$dark, $language)', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          AliceLanguage.current.value = language;
          addTearDown(() => AliceLanguage.current.value = 'en');

          final List<Widget> screens = [
            AliceCallRequestScreen(call: _call(status: 500)),
            AliceCallResponseScreen(call: _call(status: 404)),
            AliceCallListItemWidget(_call(status: 503), (_) {}),
            AliceLogListWidget(
              logsStream: Stream.value(logs),
              initialLogs: logs,
              scrollController: ScrollController(),
            ),
          ];
          for (final Widget screen in screens) {
            await tester.pumpWidget(
              MaterialApp(
                theme: dark ? ThemeData.dark() : ThemeData.light(),
                home: Directionality(
                  textDirection: AliceLanguage.textDirection,
                  child: Scaffold(body: screen),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${screen.runtimeType}',
            );
          }
        });
      }
    }
  });
}
