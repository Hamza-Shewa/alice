import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_replay_request.dart';
import 'package:alice_http/alice_http_adapter.dart';
import 'package:alice_test/alice_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  late AliceCore aliceCore;
  late AliceHttpAdapter adapter;
  late List<http.Request> sentRequests;

  setUp(() {
    registerFallbackValue(AliceHttpCall(0));
    aliceCore = AliceCoreMock();
    when(() => aliceCore.addCall(any())).thenAnswer((_) {});
    sentRequests = [];
    adapter = AliceHttpAdapter(
      replayClient: MockClient((http.Request request) async {
        sentRequests.add(request);
        return http.Response('{"id": 2}', 201, request: request);
      }),
    )..injectCore(aliceCore);
  });

  group('AliceHttpAdapter replay', () {
    test('should replay only calls made by the http package', () {
      expect(
        adapter.canReplay(
          AliceHttpCall(1)..client = AliceHttpAdapter.clientName,
        ),
        true,
      );
      expect(adapter.canReplay(AliceHttpCall(1)..client = 'Dio'), false);
    });

    test('should send the request and record the new call', () async {
      await adapter.replay(
        const AliceReplayRequest(
          method: 'POST',
          url: 'https://test.com/items?page=1',
          headers: {'content-type': 'application/json', 'x-token': 'abc'},
          body: '{"name":"a"}',
        ),
      );

      final http.Request sent = sentRequests.single;
      expect(sent.method, 'POST');
      expect(sent.url.toString(), 'https://test.com/items?page=1');
      expect(sent.headers['x-token'], 'abc');
      expect(sent.body, '{"name":"a"}');

      final AliceHttpCall call =
          verify(() => aliceCore.addCall(captureAny())).captured.single
              as AliceHttpCall;
      expect(call.client, AliceHttpAdapter.clientName);
      expect(call.method, 'POST');
      expect(call.response?.status, 201);
      expect(call.response?.body, '{"id": 2}');
    });
  });
}
