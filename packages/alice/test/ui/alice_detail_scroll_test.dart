import 'dart:convert';

import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_request_screen.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Call with enough data to make the detail screens several screens tall: a
/// large JSON body, query parameters, form fields and headers.
AliceHttpCall _largeCall() {
  final String body = jsonEncode({
    'items': [
      for (int i = 0; i < 200; i++)
        {
          'id': i,
          'name': 'Item $i',
          'tags': ['a', 'b'],
          'active': i.isEven,
        },
    ],
  });
  return AliceHttpCall(1)
    ..method = 'POST'
    ..server = 'api.example.com'
    ..endpoint = '/v1/items'
    ..uri = 'https://api.example.com/v1/items?page=1'
    ..client = 'Dio'
    ..secure = true
    ..loading = false
    ..duration = 342
    ..request =
        (AliceHttpRequest()
          ..time = DateTime(2026, 10, 7, 14, 3, 1)
          ..size = body.length
          ..contentType = 'application/json'
          ..headers = {for (int i = 0; i < 8; i++) 'x-header-$i': 'value $i'}
          ..queryParameters = {for (int i = 0; i < 20; i++) 'param$i': '$i'}
          ..formDataFields = [
            for (int i = 0; i < 20; i++) AliceFormDataField('field$i', '$i'),
          ]
          ..body = body)
    ..response =
        (AliceHttpResponse()
          ..status = 200
          ..size = body.length
          ..headers = {'content-type': 'application/json'}
          ..body = body
          ..time = DateTime(2026, 10, 7, 14, 3, 2));
}

/// Work done by the framework while the screen scrolls.
class _ScrollWork {
  /// Widgets rebuilt although they were already on screen.
  final Map<Type, int> rebuilt = {};

  /// Widgets built from scratch, for example after they scrolled back in.
  final Map<Type, int> mounted = {};

  int mountedOf(Type type) => mounted[type] ?? 0;
}

/// Scrolls the first [Scrollable] down to the end and back to the top
/// [rounds] times in small steps, one frame per step, and records which
/// widgets were built in the meantime.
Future<_ScrollWork> _scrollUpAndDown(
  WidgetTester tester, {
  int rounds = 3,
}) async {
  final _ScrollWork work = _ScrollWork();
  final Finder scrollable = find.byType(Scrollable).first;
  final ScrollPosition position =
      tester.state<ScrollableState>(scrollable).position;

  debugOnRebuildDirtyWidget = (Element element, bool builtOnce) {
    final Map<Type, int> target = builtOnce ? work.rebuilt : work.mounted;
    target.update(
      element.widget.runtimeType,
      (int count) => count + 1,
      ifAbsent: () => 1,
    );
  };
  addTearDown(() => debugOnRebuildDirtyWidget = null);

  for (int round = 0; round < rounds; round++) {
    while (position.pixels < position.maxScrollExtent) {
      await tester.drag(scrollable, const Offset(0, -120));
      await tester.pump(const Duration(milliseconds: 16));
    }
    while (position.pixels > position.minScrollExtent) {
      await tester.drag(scrollable, const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 16));
    }
  }
  await tester.pumpAndSettle();

  debugOnRebuildDirtyWidget = null;
  return work;
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  // Typical phone size, so the screens are several viewports tall.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
}

/// Scrolls through the whole screen, switches JSON bodies to the raw text and
/// expands every collapsed code block on the way, so the full bodies are laid out. Returns to the top afterwards.
Future<void> _expandBodies(WidgetTester tester) async {
  final ScrollPosition position = _position(tester);
  while (true) {
    // Only buttons on screen: expanded blocks which scrolled away are kept
    // alive, but they can't be tapped.
    final Finder showMore = find.text('Show more').hitTestable();
    final Finder treeViewer = find.byWidgetPredicate(
      (Widget widget) =>
          widget is SegmentedButton &&
          widget.selected.first.toString().endsWith('tree'),
    );
    final Finder showRaw = find.descendant(
      of: treeViewer,
      matching: find.text('Raw').hitTestable(),
    );
    if (showRaw.evaluate().isNotEmpty) {
      // JSON bodies start in the tree; the raw text is the large layout.
      await tester.tap(showRaw.first);
      await tester.pumpAndSettle();
    } else if (showMore.evaluate().isNotEmpty) {
      await tester.tap(showMore.first);
      await tester.pumpAndSettle();
    } else if (position.pixels < position.maxScrollExtent) {
      position.jumpTo(
        (position.pixels + 400).clamp(0, position.maxScrollExtent),
      );
      await tester.pumpAndSettle();
    } else {
      break;
    }
  }
  position.jumpTo(0);
  await tester.pumpAndSettle();
}

ScrollPosition _position(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable).first).position;

void main() {
  group('scrolling call details', () {
    for (final (String name, Widget Function(AliceHttpCall) build, int bodies)
        in [
          ('overview', (call) => AliceCallOverviewScreen(call: call), 2),
          ('request', (call) => AliceCallRequestScreen(call: call), 1),
        ]) {
      testWidgets('$name screen does not rebuild while scrolling', (
        tester,
      ) async {
        await _pumpScreen(tester, build(_largeCall()));

        final _ScrollWork work = await _scrollUpAndDown(tester);

        expect(tester.takeException(), isNull);
        expect(
          work.rebuilt.keys.where(
            (Type type) => type.toString().startsWith('Alice'),
          ),
          isEmpty,
          reason: 'Alice widgets were rebuilt while scrolling: ${work.rebuilt}',
        );
      });

      testWidgets('$name screen formats bodies only once while scrolling', (
        tester,
      ) async {
        await _pumpScreen(tester, build(_largeCall()));
        await _expandBodies(tester);
        final _ScrollWork work = await _scrollUpAndDown(tester);

        expect(tester.takeException(), isNull);
        // A body which scrolls out of view and back must not be decoded,
        // pretty printed and laid out again: that is what makes scrolling
        // stutter on large responses.
        expect(work.mountedOf(AliceFormattedBodyBlock), 0);
        expect(work.mountedOf(AliceCodeBlock), 0);
        expect(
          find.byType(AliceFormattedBodyBlock, skipOffstage: false),
          findsNWidgets(bodies),
        );
      });

      testWidgets('$name screen scrolls to the end and back', (tester) async {
        await _pumpScreen(tester, build(_largeCall()));
        await _expandBodies(tester);
        final ScrollPosition position = _position(tester);
        expect(position.maxScrollExtent, greaterThan(0));

        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(find.textContaining('"id": 199'), findsWidgets);

        position.jumpTo(0);
        await tester.pumpAndSettle();
        expect(find.text('POST'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
