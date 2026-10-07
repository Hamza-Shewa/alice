import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/calls_list/widget/alice_call_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call({int? status, bool loading = false}) =>
    AliceHttpCall(1)
      ..method = 'get'
      ..endpoint = '/v1/users'
      ..server = 'api.example.com'
      ..loading = loading
      ..request = (AliceHttpRequest()..time = DateTime(2026, 1, 1, 9, 5, 7, 42))
      ..response = loading ? null : (AliceHttpResponse()..status = status);

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

void main() {
  testWidgets('renders method badge, endpoint, server and status', (
    tester,
  ) async {
    await _pump(tester, AliceCallListItemWidget(_call(status: 201), (_) {}));

    expect(find.text('GET'), findsOneWidget);
    expect(find.text('/v1/users'), findsOneWidget);
    expect(find.text('api.example.com'), findsOneWidget);
    expect(find.text('201'), findsOneWidget);
    expect(find.text('09:05:07.042'), findsOneWidget);
  });

  testWidgets('renders ERR for failed call', (tester) async {
    await _pump(tester, AliceCallListItemWidget(_call(status: -1), (_) {}));

    expect(find.text('ERR'), findsOneWidget);
  });

  testWidgets('renders progress indicator while loading', (tester) async {
    await _pump(tester, AliceCallListItemWidget(_call(loading: true), (_) {}));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('calls callback on tap', (tester) async {
    AliceHttpCall? tapped;
    final call = _call(status: 200);
    await _pump(tester, AliceCallListItemWidget(call, (c) => tapped = c));

    await tester.tap(find.text('/v1/users'));

    expect(tapped, call);
  });
}
