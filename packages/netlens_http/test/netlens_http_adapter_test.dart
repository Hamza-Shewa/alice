import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:netlens_http/netlens_http_adapter.dart';
import 'package:netlens_test/netlens_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  late NetLensCore netLensCore;
  late NetLensHttpAdapter adapter;
  late List<http.Request> sentRequests;

  setUp(() {
    registerFallbackValue(NetLensHttpCall(0));
    netLensCore = NetLensCoreMock();
    when(() => netLensCore.addCall(any())).thenAnswer((_) {});
    sentRequests = [];
    adapter = NetLensHttpAdapter(
      replayClient: MockClient((http.Request request) async {
        sentRequests.add(request);
        return http.Response('{"id": 2}', 201, request: request);
      }),
    )..injectCore(netLensCore);
  });

  group('NetLensHttpAdapter replay', () {
    test('should replay only calls made by the http package', () {
      expect(
        adapter.canReplay(
          NetLensHttpCall(1)..client = NetLensHttpAdapter.clientName,
        ),
        true,
      );
      expect(adapter.canReplay(NetLensHttpCall(1)..client = 'Dio'), false);
    });

    test('should send the request and record the new call', () async {
      await adapter.replay(
        const NetLensReplayRequest(
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

      final NetLensHttpCall call =
          verify(() => netLensCore.addCall(captureAny())).captured.single
              as NetLensHttpCall;
      expect(call.client, NetLensHttpAdapter.clientName);
      expect(call.method, 'POST');
      expect(call.response?.status, 201);
      expect(call.response?.body, '{"id": 2}');
    });
  });
}
