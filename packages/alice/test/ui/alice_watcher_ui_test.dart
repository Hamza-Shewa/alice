import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_request_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_response_screen.dart';
import 'package:alice/ui/calls_list/widget/alice_call_list_item_widget.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:alice/ui/common/alice_settings.dart';
import 'package:alice/ui/watcher/alice_watcher_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call(dynamic body) =>
    AliceHttpCall(1)
      ..method = 'POST'
      ..server = 'api.example.com'
      ..endpoint = '/v1/users'
      ..uri = 'https://api.example.com/v1/users'
      ..client = 'Dio'
      ..secure = true
      ..loading = false
      ..duration = 120
      ..request = (AliceHttpRequest()..time = DateTime(2026))
      ..response =
          (AliceHttpResponse()
            ..status = 200
            ..headers = {'content-type': 'application/json'}
            ..body = body
            ..time = DateTime(2026));

void main() {
  final AliceWatcher watcher = AliceWatcher.instance;
  late AliceCore core;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    watcher.reset();
    core = AliceCore(
      configuration: AliceConfiguration(
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

  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

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
      await pump(tester, AliceCallListItemWidget(_call({'type': 2}), (_) {}));
      expect(find.textContaining('type 2'), findsNothing);
    });

    testWidgets('shows on the list card', (tester) async {
      useTypeAsStatus();
      await pump(tester, AliceCallListItemWidget(_call({'type': 2}), (_) {}));

      expect(find.text('200'), findsOneWidget);
      expect(find.text('type 2 · Failed'), findsOneWidget);
      expect(find.text('Frontend issue'), findsOneWidget);
    });

    testWidgets('shows success and server down', (tester) async {
      useTypeAsStatus();
      await pump(tester, AliceCallListItemWidget(_call({'type': 1}), (_) {}));
      expect(find.text('type 1 · Success'), findsOneWidget);

      await pump(tester, AliceCallListItemWidget(_call({'type': 3}), (_) {}));
      expect(find.text('type 3 · Server is down'), findsOneWidget);
      expect(find.text('Backend issue'), findsOneWidget);
    });

    testWidgets('shows in the overview, request and response views', (
      tester,
    ) async {
      useTypeAsStatus();
      final AliceHttpCall call = _call({'type': 2});

      await pump(tester, AliceCallOverviewScreen(call: call));
      expect(find.text('type 2 · Failed'), findsOneWidget);
      expect(find.text('Validation or business error'), findsOneWidget);

      await pump(tester, AliceCallRequestScreen(call: call));
      expect(find.text('type 2 · Failed'), findsOneWidget);

      await pump(tester, AliceCallResponseScreen(call: call));
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
            appBar: AppBar(actions: [AliceSettingsButton(core: core)]),
          ),
        ),
      );
      await tester.tap(find.byType(AliceSettingsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Response watcher'));
      await tester.pumpAndSettle();
      expect(find.byType(AliceWatcherPage), findsOneWidget);
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
        AliceWatchOutcome.serverDown,
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
        AliceLanguage.current.value = language;
        addTearDown(() => AliceLanguage.current.value = 'en');
        useTypeAsStatus();
        watcher.fields.single.values[2].meaning =
            'A very long explanation of what a server error means for us';

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            home: AliceWatcherPage(core: core),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (final Widget screen in [
          AliceCallListItemWidget(_call({'type': 3}), (_) {}),
          AliceCallOverviewScreen(call: _call({'type': 3})),
          AliceCallResponseScreen(call: _call({'type': 3})),
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
