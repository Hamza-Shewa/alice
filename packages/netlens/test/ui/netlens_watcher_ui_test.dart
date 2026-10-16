import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_overview_screen.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_request_screen.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_response_screen.dart';
import 'package:netlens/ui/calls_list/widget/netlens_call_list_item_widget.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_settings.dart';
import 'package:netlens/ui/watcher/netlens_watcher_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

NetLensHttpCall _call(dynamic body) =>
    NetLensHttpCall(1)
      ..method = 'POST'
      ..server = 'api.example.com'
      ..endpoint = '/v1/users'
      ..uri = 'https://api.example.com/v1/users'
      ..client = 'Dio'
      ..secure = true
      ..loading = false
      ..duration = 120
      ..request = (NetLensHttpRequest()..time = DateTime(2026))
      ..response =
          (NetLensHttpResponse()
            ..status = 200
            ..headers = {'content-type': 'application/json'}
            ..body = body
            ..time = DateTime(2026));

void main() {
  final NetLensWatcher watcher = NetLensWatcher.instance;
  late NetLensCore core;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    watcher.reset();
    core = NetLensCore(
      configuration: NetLensConfiguration(
        showNotification: false,
        showInspectorOnShake: false,
        navigatorKey: navigatorKey,
      ),
    );
  });
  tearDown(() {
    core.dispose();
    watcher.reset();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    // Watcher changes are saved after a debounce. Let the save timer fire, so
    // no timer is pending when the test ends.
    await tester.pump(const Duration(milliseconds: 300));
  }

  void useTypeAsStatus() {
    watcher.fields.single.useAsStatus = true;
    watcher.changed();
  }

  void ignoreType() {
    watcher.fields.single.useAsStatus = false;
    watcher.changed();
  }

  group('watcher result next to the status', () {
    testWidgets('is hidden until the field is used as status', (tester) async {
      ignoreType();
      await pump(tester, NetLensCallListItemWidget(_call({'type': 2}), (_) {}));
      expect(find.textContaining('type 2'), findsNothing);
    });

    testWidgets('shows on the list card', (tester) async {
      useTypeAsStatus();
      await pump(tester, NetLensCallListItemWidget(_call({'type': 2}), (_) {}));

      expect(find.text('200'), findsOneWidget);
      expect(find.text('type 2 · Failed'), findsOneWidget);
      expect(find.text('Frontend issue'), findsOneWidget);
    });

    testWidgets('shows success and server down', (tester) async {
      useTypeAsStatus();
      await pump(tester, NetLensCallListItemWidget(_call({'type': 1}), (_) {}));
      expect(find.text('type 1 · Success'), findsOneWidget);

      await pump(tester, NetLensCallListItemWidget(_call({'type': 3}), (_) {}));
      expect(find.text('type 3 · Server is down'), findsOneWidget);
      expect(find.text('Backend issue'), findsOneWidget);
    });

    testWidgets('shows in the overview, request and response views', (
      tester,
    ) async {
      useTypeAsStatus();
      final NetLensHttpCall call = _call({'type': 2});

      await pump(tester, NetLensCallOverviewScreen(call: call));
      expect(find.text('type 2 · Failed'), findsOneWidget);
      expect(find.text('Validation or business error'), findsOneWidget);

      await pump(tester, NetLensCallRequestScreen(call: call));
      expect(find.text('type 2 · Failed'), findsOneWidget);

      await pump(tester, NetLensCallResponseScreen(call: call));
      expect(find.text('type = 2 · Failed'), findsOneWidget);
      expect(find.text('Validation or business error'), findsOneWidget);
    });
  });

  group('watcher page', () {
    Future<void> openPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            appBar: AppBar(actions: [NetLensSettingsButton(core: core)]),
          ),
        ),
      );
      await tester.tap(find.byType(NetLensSettingsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Response watcher'));
      await tester.pumpAndSettle();
      expect(find.byType(NetLensWatcherPage), findsOneWidget);
    }

    testWidgets('opens from the settings and lists the type field', (
      tester,
    ) async {
      await openPage(tester);

      expect(find.text('type'), findsWidgets);
      // The only field is expanded and shows its values and meanings.
      expect(find.text('Validation or business error'), findsOneWidget);
      expect(find.text('Success'), findsWidgets);
      expect(find.text('Server is down'), findsWidgets);
    });

    testWidgets('turns the status code off and on', (tester) async {
      await openPage(tester);
      expect(watcher.fields.single.useAsStatus, isTrue);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(watcher.fields.single.useAsStatus, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(watcher.fields.single.useAsStatus, isTrue);
    });

    testWidgets('changes what a value means', (tester) async {
      await openPage(tester);

      await tester.tap(find.text('Failed').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Server is down').last);
      await tester.pumpAndSettle();

      expect(
        watcher.fields.single.values[1].outcome,
        NetLensWatchOutcome.serverDown,
      );
    });

    testWidgets('adds a value and a field', (tester) async {
      await openPage(tester);

      await tester.tap(find.text('Add value'));
      await tester.pumpAndSettle();
      expect(watcher.fields.single.values.length, 4);

      await tester.tap(find.text('Add field'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'data.code',
      );
      await tester.tap(find.text('Add field').last);
      await tester.pumpAndSettle();

      expect(watcher.fields.map((f) => f.path), ['type', 'data.code']);
    });
  });

  group('layout', () {
    for (final String language in ['en', 'ar']) {
      testWidgets('watcher UI fits a narrow phone ($language)', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        NetLensLanguage.current.value = language;
        addTearDown(() => NetLensLanguage.current.value = 'en');
        useTypeAsStatus();
        watcher.fields.single.values[2].meaning =
            'A very long explanation of what a server error means for us';

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: NetLensWatcherPage(core: core),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (final Widget screen in [
          NetLensCallListItemWidget(_call({'type': 3}), (_) {}),
          NetLensCallOverviewScreen(call: _call({'type': 3})),
          NetLensCallResponseScreen(call: _call({'type': 3})),
        ]) {
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType}',
          );
        }
      });
    }
  });
}
