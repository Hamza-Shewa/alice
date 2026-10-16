import 'package:netlens/core/netlens_adapter.dart';
import 'package:netlens/core/netlens_call_replayer.dart';
import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_response_screen.dart';
import 'package:netlens/ui/calls_list/widget/netlens_call_list_item_widget.dart';
import 'package:netlens/ui/common/netlens_json_viewer.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';
import 'package:netlens/ui/replay/netlens_replay_page.dart';
import 'package:netlens/ui/timeline/netlens_timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

NetLensHttpCall _call(
  int id, {
  int status = 200,
  String method = 'GET',
  String endpoint = '/v1/users',
  String client = 'Dio',
  dynamic requestBody = '',
  dynamic responseBody = '{"name": "NetLens", "items": [1, 2]}',
}) =>
    NetLensHttpCall(id)
      ..method = method
      ..server = 'api.example.com'
      ..endpoint = endpoint
      ..uri = 'https://api.example.com$endpoint'
      ..client = client
      ..secure = true
      ..loading = false
      ..duration = 100 * id
      ..request =
          (NetLensHttpRequest()
            ..time = DateTime(2026).add(Duration(milliseconds: 50 * id))
            ..headers = {'Authorization': 'Bearer secret-token'}
            ..body = requestBody)
      ..response =
          (NetLensHttpResponse()
            ..status = status
            ..time = DateTime(2026)
            ..headers = {'content-type': 'application/json'}
            ..body = responseBody);

/// Adapter which records replayed requests instead of sending them.
class _FakeReplayer with NetLensAdapter implements NetLensCallReplayer {
  final List<NetLensReplayRequest> requests = [];

  @override
  bool canReplay(NetLensHttpCall call) => call.client == 'Dio';

  @override
  Future<void> replay(NetLensReplayRequest request) async {
    requests.add(request);
  }
}

void main() {
  late NetLensCore core;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    NetLensWatcher.instance.reset();
    navigatorKey = GlobalKey<NavigatorState>();
    core = NetLensCore(
      configuration: NetLensConfiguration(
        showNotification: false,
        showInspectorOnShake: false,
        navigatorKey: navigatorKey,
      ),
    );
  });

  tearDown(() => core.dispose());

  Future<void> pumpApp(WidgetTester tester, {Size? size}) async {
    tester.view.physicalSize = size ?? const Size(500, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );
  }

  group('quick filters', () {
    testWidgets('filter the calls list by status and method', (tester) async {
      core.addCall(_call(1));
      core.addCall(_call(2, status: 404, endpoint: '/v1/missing'));
      core.addCall(_call(3, method: 'POST', endpoint: '/v1/create'));
      await pumpApp(tester);
      NetLensNavigation.navigateToCallsList(core: core);
      await tester.pumpAndSettle();

      expect(find.text('/v1/missing'), findsOneWidget);
      expect(find.text('/v1/create'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('netlens_filter_status_clientError')),
      );
      await tester.pumpAndSettle();
      expect(find.text('/v1/missing'), findsOneWidget);
      expect(find.text('/v1/users'), findsNothing);
      expect(find.text('/v1/create'), findsNothing);

      await tester.tap(find.byKey(const Key('netlens_filter_clear')));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.byKey(const Key('netlens_filter_method_POST')),
        find.byKey(const Key('netlens_filter_bar')),
        const Offset(-100, 0),
      );
      await tester.tap(find.byKey(const Key('netlens_filter_method_POST')));
      await tester.pumpAndSettle();
      expect(find.text('/v1/create'), findsOneWidget);
      expect(find.text('/v1/missing'), findsNothing);

      await tester.tap(
        find.byKey(const Key('netlens_filter_status_serverError')),
      );
      await tester.pumpAndSettle();
      expect(find.text('No calls match the filters'), findsOneWidget);
    });
  });

  group('call details', () {
    testWidgets('hide sensitive headers until revealed', (tester) async {
      core.addCall(_call(1));
      await pumpApp(tester);
      NetLensNavigation.navigateToCallDetails(
        call: core.getCalls().first,
        core: core,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request'));
      await tester.pumpAndSettle();

      expect(find.text('***'), findsOneWidget);
      expect(find.text('Bearer secret-token'), findsNothing);

      await tester.tap(find.byTooltip('Show hidden values'));
      await tester.pumpAndSettle();
      expect(find.text('Bearer secret-token'), findsOneWidget);
      expect(find.byTooltip('Hide sensitive values'), findsOneWidget);
    });

    testWidgets('offer replay only when an adapter can replay the call', (
      tester,
    ) async {
      core.addCall(_call(1));
      await pumpApp(tester);
      NetLensNavigation.navigateToCallDetails(
        call: core.getCalls().first,
        core: core,
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit and resend'), findsNothing);

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      core.addAdapter(_FakeReplayer());
      NetLensNavigation.navigateToCallDetails(
        call: core.getCalls().first,
        core: core,
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit and resend'), findsOneWidget);
    });
  });

  group('replay page', () {
    testWidgets('sends the edited request with the original headers', (
      tester,
    ) async {
      final _FakeReplayer replayer = _FakeReplayer();
      core.addAdapter(replayer);
      core.addCall(_call(1, method: 'POST', requestBody: {'name': 'a'}));
      await pumpApp(tester);
      NetLensNavigation.navigateToCallDetails(
        call: core.getCalls().first,
        core: core,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit and resend'));
      await tester.pumpAndSettle();
      expect(find.byType(NetLensReplayPage), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('netlens_replay_url')),
        'https://api.example.com/v2/users',
      );
      await tester.tap(find.byKey(const Key('netlens_replay_send')));
      await tester.pumpAndSettle();

      final NetLensReplayRequest request = replayer.requests.single;
      expect(request.method, 'POST');
      expect(request.url, 'https://api.example.com/v2/users');
      // The editor starts from the real values, not from the masked ones.
      expect(request.headers, {'Authorization': 'Bearer secret-token'});
      expect(request.body, '{"name":"a"}');
      expect(find.byType(NetLensReplayPage), findsNothing);
      expect(
        find.text('Request sent. The new call is at the top of the list.'),
        findsOneWidget,
      );
    });

    testWidgets('validates URL and headers', (tester) async {
      final _FakeReplayer replayer = _FakeReplayer();
      core.addAdapter(replayer);
      core.addCall(_call(1));
      await pumpApp(tester);
      NetLensNavigation.navigateToReplay(
        call: core.getCalls().first,
        core: core,
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('netlens_replay_url')),
        'abc',
      );
      await tester.enterText(
        find.byKey(const Key('netlens_replay_headers')),
        'Accept: json\nnot a header',
      );
      await tester.tap(find.byKey(const Key('netlens_replay_send')));
      await tester.pumpAndSettle();

      expect(replayer.requests, isEmpty);
      expect(
        find.text(
          'Enter a full URL, for example https://api.example.com/users',
        ),
        findsOneWidget,
      );
      expect(
        find.text("Line 2 isn't a header. Use Name: value."),
        findsOneWidget,
      );
    });
  });

  group('JSON viewer', () {
    Future<void> pumpResponse(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NetLensCallResponseScreen(call: _call(1))),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows a tree which can be expanded and searched', (
      tester,
    ) async {
      await pumpResponse(tester);
      expect(find.byType(NetLensJsonViewer), findsOneWidget);
      expect(find.textContaining('"name": "NetLens"'), findsOneWidget);
      expect(find.textContaining('"items": [2]'), findsOneWidget);
      // Small containers of the first level start expanded.
      expect(find.textContaining('0: 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Collapse all'));
      await tester.pumpAndSettle();
      expect(find.textContaining('0: 1'), findsNothing);

      await tester.tap(find.byTooltip('Expand all'));
      await tester.pumpAndSettle();
      expect(find.textContaining('0: 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Collapse all'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Search keys and values'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '2');
      await tester.pumpAndSettle();
      // Search expands the list which holds the match.
      expect(find.textContaining('1: 2'), findsOneWidget);
      expect(find.text('1 matches'), findsOneWidget);
    });

    testWidgets('switches to the raw text', (tester) async {
      await pumpResponse(tester);
      await tester.tap(find.text('Raw'));
      await tester.pumpAndSettle();
      expect(find.textContaining('"name": "NetLens",\n'), findsOneWidget);
    });
  });

  group('GraphQL', () {
    testWidgets('list rows show the operation name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NetLensCallListItemWidget(
              _call(
                1,
                method: 'POST',
                endpoint: '/graphql',
                requestBody: {'query': 'query GetUser { user { id } }'},
                responseBody: '{"errors": [{"message": "denied"}]}',
              ),
              (_) {},
            ),
          ),
        ),
      );
      expect(find.text('query GetUser'), findsOneWidget);
      expect(find.text('GraphQL query'), findsOneWidget);
      expect(find.text('GraphQL errors'), findsOneWidget);
      expect(find.text('api.example.com/graphql'), findsOneWidget);
    });
  });

  group('timeline', () {
    testWidgets('shows calls on a time axis and opens them', (tester) async {
      core.addCall(_call(1));
      core.addCall(_call(2, endpoint: '/v1/slow'));
      await pumpApp(tester);
      NetLensNavigation.navigateToTimeline(core: core);
      await tester.pumpAndSettle();

      expect(find.byType(NetLensTimelinePage), findsOneWidget);
      expect(find.text('2 calls over 250 ms, up to 2 at once'), findsOneWidget);
      await tester.tap(find.text('/v1/slow'));
      await tester.pumpAndSettle();
      expect(find.text('NetLens - HTTP Call Details'), findsOneWidget);
    });
  });

  group('layout', () {
    for (final String language in ['en', 'ar']) {
      testWidgets('new pages fit a narrow phone ($language)', (tester) async {
        NetLensLanguage.current.value = language;
        addTearDown(() => NetLensLanguage.current.value = 'en');
        core.addAdapter(_FakeReplayer());
        core.addCall(_call(1));
        core.addCall(_call(2, status: 500, method: 'DELETE'));
        await pumpApp(tester, size: const Size(320, 640));

        final Map<String, VoidCallback> pages = {
          'calls list': () => NetLensNavigation.navigateToCallsList(core: core),
          'call details':
              () => NetLensNavigation.navigateToCallDetails(
                call: core.getCalls().first,
                core: core,
              ),
          'replay':
              () => NetLensNavigation.navigateToReplay(
                call: core.getCalls().first,
                core: core,
              ),
          'timeline': () => NetLensNavigation.navigateToTimeline(core: core),
          'stats': () => NetLensNavigation.navigateToStats(core: core),
        };
        for (final MapEntry<String, VoidCallback> page in pages.entries) {
          page.value();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: page.key);
        }
      });
    }
  });
}
