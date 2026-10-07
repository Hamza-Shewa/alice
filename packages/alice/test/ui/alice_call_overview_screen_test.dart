import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call({String uri = 'https://api.example.com/v1/users'}) =>
    AliceHttpCall(1)
      ..method = 'GET'
      ..server = 'api.example.com'
      ..endpoint = '/v1/users'
      ..uri = uri
      ..client = 'Dio'
      ..secure = true
      ..loading = false
      ..duration = 342
      ..request =
          (AliceHttpRequest()
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 37)
            ..size = 230
            ..headers = {'x-request-header': 'request-value'}
            ..body = 'request body text')
      ..response =
          (AliceHttpResponse()
            ..status = 200
            ..size = 1840
            ..headers = {'x-response-header': 'response-value'}
            ..body = 'response body text'
            ..time = DateTime(2026, 10, 7, 14, 3, 1, 379));

Future<void> _pump(WidgetTester tester, AliceHttpCall call) =>
    tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AliceCallOverviewScreen(call: call))),
    );

void main() {
  testWidgets('renders summary, stats and sections', (tester) async {
    await _pump(tester, _call());

    expect(find.text('https://api.example.com/v1/users'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('HTTPS'), findsOneWidget);
    expect(find.text('342 ms'), findsOneWidget);
    expect(find.text('2026-10-07 14:03:01.037'), findsOneWidget);
    expect(find.text('2026-10-07 14:03:01.379'), findsOneWidget);
    expect(find.text('TIMING'), findsOneWidget);
    expect(find.text('CONNECTION'), findsOneWidget);
    expect(find.text('MALFORMED URL'), findsNothing);
  });

  testWidgets('shows URL issue banner for malformed URL', (tester) async {
    await _pump(tester, _call(uri: 'http://192.168.1.1:505api/login'));

    expect(find.text('MALFORMED URL'), findsOneWidget);
  });

  testWidgets('copies URL to clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );

    await _pump(tester, _call());
    await tester.tap(find.text('Copy URL'));
    await tester.pump();

    expect(copied, 'https://api.example.com/v1/users');
    expect(find.text('URL copied to clipboard'), findsOneWidget);
  });

  testWidgets('renders request and response headers and bodies', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pump(tester, _call());

    expect(find.text('x-request-header'), findsOneWidget);
    expect(find.text('request-value'), findsOneWidget);
    expect(find.text('request body text'), findsOneWidget);
    expect(find.text('x-response-header'), findsOneWidget);
    expect(find.text('response-value'), findsOneWidget);
    expect(find.text('response body text'), findsOneWidget);
  });

  testWidgets('explains status code on tap', (tester) async {
    await _pump(tester, _call());

    await tester.tap(find.text('200'));
    await tester.pumpAndSettle();

    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('The request succeeded.'), findsOneWidget);
  });
}
