import 'package:flutter/foundation.dart';
import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/ui/calls_list/page/netlens_calls_list_page.dart';
import 'package:netlens/ui/call_details/page/netlens_call_details_page.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_overview_screen.dart';
import 'package:netlens/ui/common/netlens_app_bar.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NetLensCore core;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    core = NetLensCore(
      configuration: NetLensConfiguration(
        showNotification: false,
        showInspectorOnShake: false,
        navigatorKey: navigatorKey,
      ),
    );
    core.addCall(
      NetLensHttpCall(1)
        ..method = 'GET'
        ..server = 'api.example.com'
        ..endpoint = '/v1/users'
        ..uri = 'https://api.example.com/v1/users'
        ..client = 'Dio'
        ..secure = true
        ..loading = false
        ..request = (NetLensHttpRequest()..time = DateTime(2026))
        ..response =
            (NetLensHttpResponse()
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
    NetLensNavigation.navigateToCallsList(core: core);
    await tester.pumpAndSettle();
    expect(find.byType(NetLensAppBar), findsOneWidget);

    NetLensNavigation.navigateToCallDetails(
      call: core.getCalls().first,
      core: core,
    );
    // Midway through the transition both pages and the hero are present.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    // While flying, the bar still shows content of both pages (cross-fade),
    // it must not be an empty surface.
    expect(find.text('NetLens - HTTP Call Details'), findsOneWidget);
    expect(find.text('NetLens'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(NetLensAppBar), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);

    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    expect(find.text('NetLens - HTTP Call Details'), findsOneWidget);
    expect(find.text('NetLens'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(NetLensAppBar), findsOneWidget);
    expect(find.text('NetLens'), findsOneWidget);
  });

  testWidgets('new page is opaque during the transition', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    NetLensNavigation.navigateToCallsList(core: core);
    for (int i = 0; i < 5; i++) {
      await tester.pump();
      if (find.byType(NetLensCallsListPage).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 100));

    // Page of the host app must not shine through the page which is entering.
    final Iterable<double> opacities = find
        .ancestor(
          of: find.byType(NetLensCallsListPage),
          matching: find.byType(FadeTransition),
        )
        .evaluate()
        .map((e) => (e.widget as FadeTransition).opacity.value);
    expect(opacities.where((double value) => value < 1), isEmpty);
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('pages opened from NetLens fade in place, the first one slides', (
    tester,
  ) async {
    await pumpApp(tester);

    NetLensNavigation.navigateToCallsList(core: core);
    for (int i = 0; i < 5; i++) {
      await tester.pump();
      if (find.byType(NetLensCallsListPage).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.getTopLeft(find.byType(NetLensCallsListPage)).dx,
      greaterThan(0),
      reason: 'the first page slides in',
    );
    await tester.pumpAndSettle();

    NetLensNavigation.navigateToCallDetails(
      call: core.getCalls().first,
      core: core,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The list is not pushed aside and the details page does not move, so
    // the app bar hero can morph in place.
    expect(tester.getTopLeft(find.byType(NetLensCallsListPage)).dx, 0);
    expect(tester.getTopLeft(find.byType(NetLensCallDetailsPage)).dx, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('details page ignores updates of other calls', (tester) async {
    await pumpApp(tester);
    NetLensNavigation.navigateToCallDetails(
      call: core.getCalls().first,
      core: core,
    );
    await tester.pumpAndSettle();
    final Widget before = tester.widget(find.byType(NetLensCallOverviewScreen));

    core.addCall(NetLensHttpCall(2)..uri = 'https://a.com/other');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Same widget instance: nothing was rebuilt, so scrolling isn't
    // interrupted by traffic of other requests.
    expect(
      identical(before, tester.widget(find.byType(NetLensCallOverviewScreen))),
      isTrue,
    );
  });
}
