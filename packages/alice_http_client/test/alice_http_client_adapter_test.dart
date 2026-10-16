import 'dart:convert';
import 'dart:io';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_replay_request.dart';
import 'package:alice_http_client/alice_http_client_adapter.dart';
import 'package:alice_test/alice_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  late AliceCore aliceCore;
  late AliceHttpClientAdapter adapter;
  late HttpServer server;
  late List<(String, String, String?)> received;

  setUp(() async {
    registerFallbackValue(AliceHttpCall(0));
    registerFallbackValue(AliceHttpResponse());
    aliceCore = AliceCoreMock();
    when(() => aliceCore.addCall(any())).thenAnswer((_) {});
    when(() => aliceCore.addResponse(any(), any())).thenAnswer((_) {});
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
    adapter = AliceHttpClientAdapter()..injectCore(aliceCore);
  });

  tearDown(() => server.close(force: true));

  group('AliceHttpClientAdapter replay', () {
    test('should replay only calls made by HttpClient', () {
      expect(
        adapter.canReplay(
          AliceHttpCall(1)..client = AliceHttpClientAdapter.clientName,
        ),
        true,
      );
      expect(adapter.canReplay(AliceHttpCall(1)..client = 'Dio'), false);
    });

    test('should send the request and record the new call', () async {
      await adapter.replay(
        AliceReplayRequest(
          method: 'POST',
          url: 'http://${server.address.host}:${server.port}/items',
          headers: const {'x-token': 'abc'},
          body: '{"name":"a"}',
        ),
      );

      expect(received.single, ('POST', '{"name":"a"}', 'abc'));
      final AliceHttpCall call =
          verify(() => aliceCore.addCall(captureAny())).captured.single
              as AliceHttpCall;
      expect(call.method, 'POST');
      expect(call.endpoint, '/items');
      expect(call.request?.headers['x-token'], 'abc');
      final AliceHttpResponse response =
          verify(
                () => aliceCore.addResponse(captureAny(), call.id),
              ).captured.single
              as AliceHttpResponse;
      expect(response.status, 201);
      expect(response.body, '{"id": 2}');
    });
  });
}
