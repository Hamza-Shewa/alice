import 'package:flutter/foundation.dart';
import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/calls_list/page/alice_calls_list_page.dart';
import 'package:alice/ui/call_details/page/alice_call_details_page.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_screen.dart';
import 'package:alice/ui/common/alice_app_bar.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AliceCore core;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    core = AliceCore(
      configuration: AliceConfiguration(
        showNotification: false,
        showInspectorOnShake: false,
        navigatorKey: navigatorKey,
      ),
    );
    core.addCall(
      AliceHttpCall(1)
        ..method = 'GET'
        ..server = 'api.example.com'
        ..endpoint = '/v1/users'
        ..uri = 'https://api.example.com/v1/users'
        ..client = 'Dio'
        ..secure = true
        ..loading = false
        ..request = (AliceHttpRequest()..time = DateTime(2026))
        ..response =
            (AliceHttpResponse()
              ..status = 200
              ..time = DateTime(2026)),
    );
  });

  tearDown(() => core.dispose());

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const Scaffold(body: SizedBox()),
    ),
  );

  testWidgets('app bar hero flies between pages without errors', (
    tester,
  ) async {
    await pumpApp(tester);
    AliceNavigation.navigateToCallsList(core: core);
    await tester.pumpAndSettle();
    expect(find.byType(AliceAppBar), findsOneWidget);

    AliceNavigation.navigateToCallDetails(
      call: core.getCalls().first,
      core: core,
    );
    // Midway through the transition both pages and the hero are present.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    // While flying, the bar still shows content of both pages (cross-fade),
    // it must not be an empty surface.
    expect(find.text('Alice - HTTP Call Details'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(AliceAppBar), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);

    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    expect(find.text('Alice - HTTP Call Details'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(AliceAppBar), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
  });

  testWidgets('new page is opaque during the transition', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    AliceNavigation.navigateToCallsList(core: core);
    for (int i = 0; i < 5; i++) {
      await tester.pump();
      if (find.byType(AliceCallsListPage).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 100));

    // Page of the host app must not shine through the page which is entering.
    final Iterable<double> opacities = find
        .ancestor(
          of: find.byType(AliceCallsListPage),
          matching: find.byType(FadeTransition),
        )
        .evaluate()
        .map((e) => (e.widget as FadeTransition).opacity.value);
    expect(opacities.where((double value) => value < 1), isEmpty);
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('pages opened from Alice fade in place, the first one slides', (
    tester,
  ) async {
    await pumpApp(tester);

    AliceNavigation.navigateToCallsList(core: core);
    for (int i = 0; i < 5; i++) {
      await tester.pump();
      if (find.byType(AliceCallsListPage).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.getTopLeft(find.byType(AliceCallsListPage)).dx,
      greaterThan(0),
      reason: 'the first page slides in',
    );
    await tester.pumpAndSettle();

    AliceNavigation.navigateToCallDetails(
      call: core.getCalls().first,
      core: core,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The list is not pushed aside and the details page does not move, so
    // the app bar hero can morph in place.
    expect(tester.getTopLeft(find.byType(AliceCallsListPage)).dx, 0);
    expect(tester.getTopLeft(find.byType(AliceCallDetailsPage)).dx, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('details page ignores updates of other calls', (tester) async {
    await pumpApp(tester);
    AliceNavigation.navigateToCallDetails(
      call: core.getCalls().first,
      core: core,
    );
    await tester.pumpAndSettle();
    final Widget before = tester.widget(find.byType(AliceCallOverviewScreen));

    core.addCall(AliceHttpCall(2)..uri = 'https://a.com/other');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Same widget instance: nothing was rebuilt, so scrolling isn't
    // interrupted by traffic of other requests.
    expect(
      identical(before, tester.widget(find.byType(AliceCallOverviewScreen))),
      isTrue,
    );
  });
}
