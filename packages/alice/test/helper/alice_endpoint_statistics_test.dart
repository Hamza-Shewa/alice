import 'package:alice/helper/alice_endpoint_statistics.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:test/test.dart';

AliceHttpCall _call(String endpoint, int duration, {int status = 200}) =>
    AliceHttpCall(duration)
      ..method = 'get'
      ..endpoint = endpoint
      ..loading = false
      ..duration = duration
      ..request = AliceHttpRequest()
      ..response = (AliceHttpResponse()..status = status);

void main() {
  group('AliceEndpointStatistics', () {
    test('replaces IDs in paths', () {
      expect(
        AliceEndpointStatistics.normalizePath(
          '/users/42/posts/3f2b8c1e-1d2a-4b5c-8d9e-0a1b2c3d4e5f?x=1',
        ),
        '/users/{id}/posts/{id}',
      );
      expect(
        AliceEndpointStatistics.normalizePath('/v2/users/me'),
        '/v2/users/me',
      );
    });

    test('calculates percentiles with the nearest rank', () {
      final List<int> values = [for (int i = 1; i <= 20; i++) i * 10];
      expect(AliceEndpointStatistics.percentile(values, 50), 100);
      expect(AliceEndpointStatistics.percentile(values, 95), 190);
      expect(AliceEndpointStatistics.percentile([], 95), 0);
    });

    test('groups endpoints and sorts them by p95', () {
      final List<AliceEndpointTiming> timings =
          AliceEndpointStatistics.slowest([
            _call('/users/1', 100),
            _call('/users/2', 300, status: 500),
            _call('/users/3', 200),
            _call('/health', 50),
            AliceHttpCall(9)..loading = true,
          ]);

      expect(timings.map((timing) => timing.path), ['/users/{id}', '/health']);
      final AliceEndpointTiming users = timings.first;
      expect(users.method, 'GET');
      expect(users.count, 3);
      expect(users.failures, 1);
      expect(users.p50, 200);
      expect(users.p95, 300);
      expect(users.max, 300);
    });

    test('limits the number of endpoints', () {
      expect(
        AliceEndpointStatistics.slowest([
          for (int i = 0; i < 10; i++) _call('/e$i', i),
        ], limit: 3).length,
        3,
      );
    });
  });
}
