// Renders the inspector screens used in the READMEs and on pub.dev.
//
// Run from packages/netlens:
//   flutter test screenshot_test --update-goldens
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';

const Size _screenSize = Size(390, 844);
const double _pixelRatio = 2;
final DateTime _start = DateTime(2026, 10, 16, 9, 41);

/// Loads Roboto and the Material icons from the Flutter SDK, so the
/// screenshots show real text instead of the test font.
Future<void> _loadFonts() async {
  final engineDir = File(Platform.resolvedExecutable).parent;
  final artifacts = engineDir.parent.parent;
  final fonts = Directory('${artifacts.path}/material_fonts');

  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('${fonts.path}/$name').readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold', 'Light']) {
    roboto.addFont(read('Roboto-$weight.ttf'));
  }
  await roboto.load();
  await (FontLoader('MaterialIcons')
    ..addFont(read('MaterialIcons-Regular.otf'))).load();

  // The JSON viewer asks for 'monospace', which the SDK has no font for.
  const mono = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf';
  if (File(mono).existsSync()) {
    await (FontLoader('monospace')
      ..addFont(File(mono).readAsBytes().then(ByteData.sublistView))).load();
  }
}

NetLensHttpCall _call(
  int id, {
  required String method,
  required String endpoint,
  int? status = 200,
  int duration = 120,
  int startOffset = 0,
  String server = 'api.shop.dev',
  Map<String, String> requestHeaders = const {},
  Map<String, dynamic> queryParameters = const {},
  Object? requestBody = '',
  Object? responseBody = '',
  Object? error,
}) {
  final requestTime = _start.add(Duration(milliseconds: startOffset));
  final call =
      NetLensHttpCall(id)
        ..method = method
        ..server = server
        ..endpoint = endpoint
        ..uri = 'https://$server$endpoint'
        ..client = 'Dio'
        ..secure = true
        ..loading = status == null && error == null
        ..duration = duration
        ..request =
            (NetLensHttpRequest()
              ..time = requestTime
              ..headers = {
                'accept': 'application/json',
                'user-agent': 'shop-app/4.2.0 (Android 15)',
                ...requestHeaders,
              }
              ..queryParameters = queryParameters
              ..contentType = 'application/json'
              ..body = requestBody
              ..size = utf8.encode('$requestBody').length);
  if (status != null) {
    final body =
        responseBody is String ? responseBody : jsonEncode(responseBody);
    call.response =
        NetLensHttpResponse()
          ..status = status
          ..time = requestTime.add(Duration(milliseconds: duration))
          ..headers = {
            'content-type': 'application/json; charset=utf-8',
            'set-cookie': 'session=8f1c2e9a; HttpOnly; Secure',
            'cache-control': 'no-cache',
          }
          ..body = body
          ..size = utf8.encode(body).length;
  }
  if (error != null) {
    call.error = NetLensHttpError()..error = error;
  }
  return call;
}

const _auth = {'authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.c2hvcC1hcHA'};

List<NetLensHttpCall> _sampleCalls() => [
  _call(
    1,
    method: 'POST',
    endpoint: '/v1/auth/login',
    duration: 340,
    requestHeaders: {'x-api-key': 'sk_live_51HxQe2c9a7'},
    requestBody: jsonEncode({'email': 'sara@shop.dev', 'password': 'hunter2'}),
    responseBody: {
      'access_token': 'eyJhbGciOiJIUzI1NiJ9.c2hvcC1hcHA',
      'expires_in': 3600,
      'user': {'id': 42, 'name': 'Sara'},
    },
  ),
  _call(
    2,
    method: 'GET',
    endpoint: '/v1/products?page=1&limit=3',
    startOffset: 380,
    duration: 210,
    requestHeaders: _auth,
    queryParameters: {'page': '1', 'limit': '3'},
    responseBody: {
      'page': 1,
      'total': 128,
      'items': [
        {
          'id': 1001,
          'name': 'Trail running shoes',
          'price': 89.9,
          'tags': ['sport', 'outdoor'],
          'stock': {'warehouse': 'AMS-1', 'count': 14},
        },
        {
          'id': 1002,
          'name': 'Merino beanie',
          'price': 24.5,
          'tags': ['winter'],
          'stock': {'warehouse': 'AMS-1', 'count': 0},
        },
        {
          'id': 1003,
          'name': 'Insulated bottle',
          'price': 19,
          'tags': [],
          'stock': {'warehouse': 'BER-2', 'count': 63},
        },
      ],
    },
  ),
  _call(
    3,
    method: 'DELETE',
    endpoint: '/v1/cart/items/1003',
    startOffset: 420,
    duration: 150,
    status: 204,
    requestHeaders: _auth,
  ),
  _call(
    4,
    method: 'GET',
    endpoint: '/v1/products/1002/reviews',
    startOffset: 640,
    duration: 95,
    status: 404,
    requestHeaders: _auth,
    responseBody: {'error': 'not_found', 'message': 'No reviews yet'},
  ),
  _call(
    5,
    method: 'PUT',
    endpoint: '/v1/cart/items/1001',
    startOffset: 700,
    duration: 260,
    requestHeaders: _auth,
    requestBody: jsonEncode({'qty': 2}),
    responseBody: {'id': 1001, 'qty': 2},
  ),
  _call(
    6,
    method: 'POST',
    endpoint: '/v1/checkout',
    startOffset: 980,
    duration: 1240,
    status: 503,
    requestHeaders: _auth,
    requestBody: jsonEncode({'cart': 'c_77', 'payment': 'card'}),
    responseBody: {'error': 'payment_gateway_unavailable'},
  ),
  _call(
    7,
    method: 'GET',
    endpoint: '/v1/recommendations',
    server: 'ml.shop.dev',
    startOffset: 1100,
    duration: 0,
    status: null,
    error: const SocketException('Connection reset by peer'),
    requestHeaders: _auth,
  ),
  _call(
    8,
    method: 'POST',
    endpoint: '/graphql',
    server: 'api.shop.dev',
    startOffset: 2350,
    duration: 180,
    requestHeaders: _auth,
    requestBody: jsonEncode({
      'operationName': 'GetCart',
      'query': 'query GetCart { cart { id total items { sku qty } } }',
    }),
    responseBody: {
      'data': {
        'cart': {'id': 'c_77', 'total': 114.4, 'items': []},
      },
    },
  ),
  _call(
    9,
    method: 'GET',
    endpoint: '/v1/products/1001',
    startOffset: 2500,
    duration: 640,
    requestHeaders: _auth,
    responseBody: {'id': 1001, 'name': 'Trail running shoes'},
  ),
  _call(
    10,
    method: 'GET',
    endpoint: '/v1/products/1003',
    startOffset: 2560,
    duration: 0,
    status: null,
    requestHeaders: _auth,
  ),
];

void main() {
  late NetLensCore core;
  late GlobalKey<NavigatorState> navigatorKey;

  setUpAll(_loadFonts);

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
    for (final call in _sampleCalls()) {
      core.addCall(call);
    }
  });

  tearDown(() => core.dispose());

  Future<void> pumpApp(WidgetTester tester) async {
    // Draw real shadows; tests draw them as outlines by default.
    debugDisableShadows = false;
    tester.view.physicalSize = _screenSize * _pixelRatio;
    tester.view.devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );
  }

  Future<void> capture(WidgetTester tester, String name) async {
    // Pending calls keep a progress indicator spinning, so the frames are
    // pumped for a fixed time instead of until they settle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    try {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../screenshots/$name.png'),
      );
    } finally {
      debugDisableShadows = true;
    }
  }

  NetLensHttpCall callById(int id) =>
      core.getCalls().firstWhere((call) => call.id == id);

  testWidgets('calls list', (tester) async {
    await pumpApp(tester);
    NetLensNavigation.navigateToCallsList(core: core);
    await capture(tester, '1_calls');
  });

  testWidgets('response as a JSON tree', (tester) async {
    await pumpApp(tester);
    NetLensNavigation.navigateToCallDetails(call: callById(2), core: core);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Response'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_right).first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -560));
    await capture(tester, '2_json_viewer');
  });

  testWidgets('request with hidden credentials', (tester) async {
    await pumpApp(tester);
    NetLensNavigation.navigateToCallDetails(call: callById(1), core: core);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request'));
    await capture(tester, '3_request_redacted');
  });

  testWidgets('edit and resend', (tester) async {
    await pumpApp(tester);
    NetLensNavigation.navigateToReplay(core: core, call: callById(5));
    await capture(tester, '4_edit_and_resend');
  });

  testWidgets('timeline', (tester) async {
    await pumpApp(tester);
    NetLensNavigation.navigateToTimeline(core: core);
    await capture(tester, '5_timeline');
  });

  testWidgets('statistics', (tester) async {
    await pumpApp(tester);
    NetLensNavigation.navigateToStats(core: core);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -560));
    await capture(tester, '6_statistics');
  });
}
