import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_error_screen.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_overview_screen.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_response_screen.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_settings.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

NetLensHttpCall _call({
  String? contentType,
  NetLensHttpError? error,
  int requestSize = 230,
  int responseSize = 1840,
}) =>
    NetLensHttpCall(1)
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
          (NetLensHttpRequest()
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 37)
            ..size = requestSize
            ..body = 'request body text')
      ..response =
          (NetLensHttpResponse()
            ..status = 200
            ..size = responseSize
            ..headers = {if (contentType != null) 'content-type': contentType}
            ..body = 'response body text'
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 379));

Future<void> _pump(WidgetTester tester, Widget screen, {Locale? locale}) =>
    tester.pumpWidget(
      MaterialApp(locale: locale, home: Scaffold(body: screen)),
    );

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
final NetLensCore _core = NetLensCore(
  configuration: NetLensConfiguration(
    showNotification: false,
    showInspectorOnShake: false,
    navigatorKey: _navigatorKey,
  ),
);

void main() {
  tearDown(() => NetLensLanguage.current.value = NetLensLanguage.defaultCode);

  testWidgets('uses English even when app locale is Arabic', (tester) async {
    await _pump(
      tester,
      NetLensCallOverviewScreen(call: _call()),
      locale: const Locale('ar'),
    );

    expect(find.text('TIMING'), findsOneWidget);
  });

  testWidgets('settings sheet changes language and theme', (tester) async {
    addTearDown(() => NetLensTheme.themeMode.value = ThemeMode.system);
    await _pump(tester, NetLensSettingsButton(core: _core));

    await tester.tap(find.byType(NetLensSettingsButton));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Polski'), findsNothing);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(NetLensTheme.themeMode.value, ThemeMode.dark);

    // Selected segments are red, the others are not.
    Color? backgroundOf(String label) {
      final Material material = tester.widget(
        find
            .ancestor(of: find.text(label), matching: find.byType(Material))
            .first,
      );
      return material.color;
    }

    expect(backgroundOf('Dark'), NetLensTheme.lightRed);
    expect(backgroundOf('Light'), isNot(NetLensTheme.lightRed));

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(NetLensLanguage.current.value, 'ar');
    expect(NetLensLanguage.textDirection, TextDirection.rtl);
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('stat tiles have the same height', (tester) async {
    await _pump(
      tester,
      NetLensCallOverviewScreen(
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
    final NetLensHttpError error =
        NetLensHttpError()
          ..error = const FormatException('bad payload')
          ..stackTrace = StackTrace.fromString('#0 main (file.dart:1:1)');
    await _pump(tester, NetLensCallErrorScreen(call: _call(error: error)));

    expect(find.text('FormatException'), findsOneWidget);
    expect(find.textContaining('bad payload'), findsOneWidget);
    expect(find.textContaining('#0 main'), findsOneWidget);
  });

  testWidgets('error screen shows empty state without error', (tester) async {
    await _pump(tester, NetLensCallErrorScreen(call: _call()));

    expect(find.text('Nothing to display here'), findsOneWidget);
  });

  testWidgets('unsupported body can be revealed as text', (tester) async {
    await _pump(
      tester,
      NetLensCallResponseScreen(call: _call(contentType: 'application/pdf')),
    );

    expect(find.text('Unsupported content'), findsOneWidget);
    expect(find.text('application/pdf'), findsWidgets);
    expect(find.text('response body text'), findsNothing);

    await tester.tap(find.text('Show unsupported body'));
    await tester.pump();

    expect(find.text('response body text'), findsOneWidget);
  });
}
