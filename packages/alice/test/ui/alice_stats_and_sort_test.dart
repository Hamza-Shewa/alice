import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:alice/ui/calls_list/widget/alice_sort_dialog.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/stats/alice_stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call(
  int id, {
  required int status,
  int duration = 100,
  String method = 'GET',
}) =>
    AliceHttpCall(id)
      ..method = method
      ..server = 'api.example.com'
      ..endpoint = '/v1/users'
      ..uri = 'https://api.example.com/v1/users'
      ..secure = true
      ..loading = false
      ..duration = duration
      ..request = (AliceHttpRequest()..size = 100)
      ..response =
          (AliceHttpResponse()
            ..status = status
            ..size = 2048);

void main() {
  late AliceCore core;

  setUp(() {
    AliceWatcher.instance.reset();
    core = AliceCore(
      configuration: AliceConfiguration(
        showNotification: false,
        showInspectorOnShake: false,
      ),
    );
  });
  tearDown(() {
    core.dispose();
    AliceLanguage.current.value = 'en';
    AliceTheme.themeMode.value = ThemeMode.system;
  });

  Future<void> pumpStats(WidgetTester tester) =>
      tester.pumpWidget(MaterialApp(home: AliceStatsPage(core)));

  group('stats page', () {
    testWidgets('shows totals, success rate and breakdowns', (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      core.addCall(_call(1, status: 200, duration: 100));
      core.addCall(_call(2, status: 200, duration: 300, method: 'POST'));
      core.addCall(_call(3, status: 404));
      core.addCall(_call(4, status: 500));
      await pumpStats(tester);

      expect(find.text('4'), findsWidgets);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Total requests'), findsOneWidget);
      expect(find.text('Success requests 2'), findsNothing);
      expect(find.text('WHO IS RESPONSIBLE'), findsOneWidget);
      expect(find.text('Frontend issue'), findsOneWidget);
      expect(find.text('Backend issue'), findsOneWidget);
      expect(find.text('Network issue'), findsOneWidget);
      // Methods are listed in the methods and slowest endpoints sections.
      expect(find.text('GET'), findsWidgets);
      expect(find.text('POST'), findsNWidgets(2));
      expect(find.text('HTTPS'), findsOneWidget);
      expect(find.text('SLOWEST ENDPOINTS'), findsOneWidget);
    });

    testWidgets('says when nothing failed and handles no calls', (
      tester,
    ) async {
      await pumpStats(tester);
      expect(find.text('No failed calls'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('updates when a call arrives', (tester) async {
      await pumpStats(tester);
      expect(find.text('No failed calls'), findsOneWidget);

      core.addCall(_call(1, status: 500));
      await tester.pump();
      await tester.pump();

      expect(find.text('No failed calls'), findsNothing);
      expect(find.text('Backend issue'), findsOneWidget);
    });

    for (final bool dark in [false, true]) {
      for (final String language in ['en', 'ar']) {
        testWidgets('fits a narrow phone (dark=$dark, $language)', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          AliceLanguage.current.value = language;
          core.addCall(_call(1, status: 200, duration: 123456));
          core.addCall(_call(2, status: 503, method: 'OPTIONS'));
          core.addCall(_call(3, status: -1));

          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? ThemeData.dark() : ThemeData.light(),
              home: AliceStatsPage(core),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          await tester.drag(find.byType(ListView), const Offset(0, -2000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('sort dialog', () {
    Future<AliceSortDialogResult?> openDialog(
      WidgetTester tester, {
      AliceCallsListSortOption option = AliceCallsListSortOption.time,
      bool ascending = false,
    }) async {
      AliceSortDialogResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (BuildContext context) => TextButton(
                  onPressed: () async {
                    result = await showDialog<AliceSortDialogResult>(
                      context: context,
                      builder:
                          (_) => AliceSortDialog(
                            sortOption: option,
                            sortAscending: ascending,
                          ),
                    );
                  },
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('lists the options and highlights the selected one', (
      tester,
    ) async {
      await openDialog(tester, option: AliceCallsListSortOption.responseCode);

      expect(find.text('Sort calls'), findsOneWidget);
      for (final String name in [
        'Create time (default)',
        'Response time',
        'Response code',
        'Response size',
        'Endpoint',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(4));
    });

    testWidgets('returns the selected option and order', (tester) async {
      AliceSortDialogResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (BuildContext context) => TextButton(
                  onPressed: () async {
                    result = await showDialog<AliceSortDialogResult>(
                      context: context,
                      builder:
                          (_) => const AliceSortDialog(
                            sortOption: AliceCallsListSortOption.time,
                            sortAscending: false,
                          ),
                    );
                  },
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Endpoint'));
      await tester.pump();
      await tester.tap(find.text('Ascending'));
      await tester.pump();
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(result?.sortOption, AliceCallsListSortOption.endpoint);
      expect(result?.sortAscending, isTrue);
    });

    testWidgets('cancel returns nothing', (tester) async {
      await openDialog(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Sort calls'), findsNothing);
    });

    for (final String language in ['en', 'ar']) {
      testWidgets('fits a narrow, short phone ($language)', (tester) async {
        tester.view.physicalSize = const Size(320, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        AliceLanguage.current.value = language;
        await openDialog(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
