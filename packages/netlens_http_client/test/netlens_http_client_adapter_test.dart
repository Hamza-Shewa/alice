import 'dart:convert';
import 'dart:io';

import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:netlens_http_client/netlens_http_client_adapter.dart';
import 'package:netlens_test/netlens_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  late NetLensCore netLensCore;
  late NetLensHttpClientAdapter adapter;
  late HttpServer server;
  late List<(String, String, String?)> received;

  setUp(() async {
    registerFallbackValue(NetLensHttpCall(0));
    registerFallbackValue(NetLensHttpResponse());
    netLensCore = NetLensCoreMock();
    when(() => netLensCore.addCall(any())).thenAnswer((_) {});
    when(() => netLensCore.addResponse(any(), any())).thenAnswer((_) {});
    received = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest request) async {
      final String body = await utf8.decoder.bind(request).join();
      received.add((request.method, body, request.headers.value('x-token')));
      request.response
        ..statusCode = 201
        ..headers.contentType = ContentType.json
        ..write('{"id": 2}');
      await request.response.close();
    });
    adapter = NetLensHttpClientAdapter()..injectCore(netLensCore);
  });

  tearDown(() => server.close(force: true));

  group('NetLensHttpClientAdapter replay', () {
    test('should replay only calls made by HttpClient', () {
      expect(
        adapter.canReplay(
          NetLensHttpCall(1)..client = NetLensHttpClientAdapter.clientName,
        ),
        true,
      );
      expect(adapter.canReplay(NetLensHttpCall(1)..client = 'Dio'), false);
    });

    test('should send the request and record the new call', () async {
      await adapter.replay(
        NetLensReplayRequest(
          method: 'POST',
          url: 'http://${server.address.host}:${server.port}/items',
          headers: const {'x-token': 'abc'},
          body: '{"name":"a"}',
        ),
      );

      expect(received.single, ('POST', '{"name":"a"}', 'abc'));
      final NetLensHttpCall call =
          verify(() => netLensCore.addCall(captureAny())).captured.single
              as NetLensHttpCall;
      expect(call.method, 'POST');
      expect(call.endpoint, '/items');
      expect(call.request?.headers['x-token'], 'abc');
      final NetLensHttpResponse response =
          verify(
                () => netLensCore.addResponse(captureAny(), call.id),
              ).captured.single
              as NetLensHttpResponse;
      expect(response.status, 201);
      expect(response.body, '{"id": 2}');
    });
  });
}
