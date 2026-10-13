import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/call_details/widget/alice_call_error_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_response_screen.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call({
  String? contentType,
  AliceHttpError? error,
  int requestSize = 230,
  int responseSize = 1840,
}) =>
    AliceHttpCall(1)
      ..method = 'GET'
      ..server = 'api.example.com'
      ..endpoint = '/v1/users'
      ..uri = 'https://api.example.com/v1/users'
      ..client = 'Dio'
      ..secure = true
      ..loading = false
      ..duration = 342
      ..error = error
      ..request =
          (AliceHttpRequest()
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 37)
            ..size = requestSize
            ..body = 'request body text')
      ..response =
          (AliceHttpResponse()
            ..status = 200
            ..size = responseSize
            ..headers = {if (contentType != null) 'content-type': contentType}
            ..body = 'response body text'
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 379));

Future<void> _pump(WidgetTester tester, Widget screen, {Locale? locale}) =>
    tester.pumpWidget(
      MaterialApp(locale: locale, home: Scaffold(body: screen)),
    );

void main() {
  tearDown(() => AliceLanguage.current.value = AliceLanguage.defaultCode);

  testWidgets('uses English even when app locale is Arabic', (tester) async {
    await _pump(
      tester,
      AliceCallOverviewScreen(call: _call()),
      locale: const Locale('ar'),
    );

    expect(find.text('TIMING'), findsOneWidget);
  });

  testWidgets('language button switches the language', (tester) async {
    await _pump(tester, const AliceLanguageButton());

    await tester.tap(find.byType(AliceLanguageButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(AliceLanguage.current.value, 'ar');
    expect(AliceLanguage.textDirection, TextDirection.rtl);
  });

  testWidgets('stat tiles have the same height', (tester) async {
    await _pump(
      tester,
      AliceCallOverviewScreen(
        call: _call(requestSize: 12345678, responseSize: 1),
      ),
    );

    final Finder tiles = find.descendant(
      of: find.byType(IntrinsicHeight),
      matching: find.byType(Expanded),
    );
    final List<double> heights = [
      for (final Element e in tiles.evaluate().take(3))
        (e.renderObject! as RenderBox).size.height,
    ];
    expect(heights.toSet().length, 1, reason: '$heights');
  });

  testWidgets('error screen shows type, message and stack trace', (
    tester,
  ) async {
    final AliceHttpError error =
        AliceHttpError()
          ..error = const FormatException('bad payload')
          ..stackTrace = StackTrace.fromString('#0 main (file.dart:1:1)');
    await _pump(tester, AliceCallErrorScreen(call: _call(error: error)));

    expect(find.text('FormatException'), findsOneWidget);
    expect(find.textContaining('bad payload'), findsOneWidget);
    expect(find.textContaining('#0 main'), findsOneWidget);
  });

  testWidgets('error screen shows empty state without error', (tester) async {
    await _pump(tester, AliceCallErrorScreen(call: _call()));

    expect(find.text('Nothing to display here'), findsOneWidget);
  });

  testWidgets('unsupported body can be revealed as text', (tester) async {
    await _pump(
      tester,
      AliceCallResponseScreen(call: _call(contentType: 'application/pdf')),
    );

    expect(find.text('Unsupported content'), findsOneWidget);
    expect(find.text('application/pdf'), findsWidgets);
    expect(find.text('response body text'), findsNothing);

    await tester.tap(find.text('Show unsupported body'));
    await tester.pump();

    expect(find.text('response body text'), findsOneWidget);
  });
}
