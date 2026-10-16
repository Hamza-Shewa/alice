import 'package:alice/helper/alice_call_filter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:test/test.dart';

AliceHttpCall _call(
  int id, {
  String method = 'GET',
  String server = 'api.example.com',
  int? status = 200,
  bool loading = false,
  Map<String, String> headers = const {},
  dynamic body = '',
}) =>
    AliceHttpCall(id)
      ..method = method
      ..server = server
      ..endpoint = '/users/$id'
      ..loading = loading
      ..request =
          (AliceHttpRequest()
            ..headers = headers
            ..body = body)
      ..response = (AliceHttpResponse()..status = status);

void main() {
  group('AliceCallStatusGroup', () {
    test('groups calls by status', () {
      expect(AliceCallStatusGroup.of(_call(1)), AliceCallStatusGroup.success);
      expect(
        AliceCallStatusGroup.of(_call(1, status: 301)),
        AliceCallStatusGroup.redirection,
      );
      expect(
        AliceCallStatusGroup.of(_call(1, status: 404)),
        AliceCallStatusGroup.clientError,
      );
      expect(
        AliceCallStatusGroup.of(_call(1, status: 503)),
        AliceCallStatusGroup.serverError,
      );
      expect(
        AliceCallStatusGroup.of(_call(1, status: -1)),
        AliceCallStatusGroup.failed,
      );
      expect(
        AliceCallStatusGroup.of(_call(1, loading: true)),
        AliceCallStatusGroup.pending,
      );
    });
  });

  group('AliceCallFilter', () {
    final List<AliceHttpCall> calls = [
      _call(1),
      _call(2, method: 'POST', status: 500, server: 'auth.example.com'),
      _call(3, status: 404, headers: {'X-Request-Id': 'abc-123'}),
      _call(4, method: 'post', body: {'name': 'Needle'}),
    ];

    List<int> ids(AliceCallFilter filter) =>
        filter.apply(calls).map((call) => call.id).toList();

    test('passes everything when empty', () {
      expect(ids(const AliceCallFilter()), [1, 2, 3, 4]);
    });

    test('filters by status group, method and host', () {
      expect(
        ids(
          const AliceCallFilter(
            statusGroups: {
              AliceCallStatusGroup.clientError,
              AliceCallStatusGroup.serverError,
            },
          ),
        ),
        [2, 3],
      );
      expect(ids(const AliceCallFilter(methods: {'POST'})), [2, 4]);
      expect(ids(const AliceCallFilter(hosts: {'auth.example.com'})), [2]);
      expect(
        ids(
          const AliceCallFilter(
            methods: {'POST'},
            statusGroups: {AliceCallStatusGroup.success},
          ),
        ),
        [4],
      );
    });

    test('searches headers and bodies ignoring case', () {
      expect(ids(const AliceCallFilter(query: 'ABC-123')), [3]);
      expect(ids(const AliceCallFilter(query: 'needle')), [4]);
      expect(ids(const AliceCallFilter(query: '/users/2')), [2]);
      expect(ids(const AliceCallFilter(query: '404')), [3]);
    });

    test('clears quick filters but keeps the query', () {
      const AliceCallFilter filter = AliceCallFilter(
        query: 'a',
        methods: {'GET'},
      );
      expect(filter.clearQuickFilters(), const AliceCallFilter(query: 'a'));
      expect(filter.hasQuickFilters, true);
      expect(filter.clearQuickFilters().hasQuickFilters, false);
    });
  });
}
