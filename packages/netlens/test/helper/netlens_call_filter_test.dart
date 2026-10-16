import 'package:netlens/helper/netlens_call_filter.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:test/test.dart';

NetLensHttpCall _call(
  int id, {
  String method = 'GET',
  String server = 'api.example.com',
  int? status = 200,
  bool loading = false,
  Map<String, String> headers = const {},
  dynamic body = '',
}) =>
    NetLensHttpCall(id)
      ..method = method
      ..server = server
      ..endpoint = '/users/$id'
      ..loading = loading
      ..request =
          (NetLensHttpRequest()
            ..headers = headers
            ..body = body)
      ..response = (NetLensHttpResponse()..status = status);

void main() {
  group('NetLensCallStatusGroup', () {
    test('groups calls by status', () {
      expect(
        NetLensCallStatusGroup.of(_call(1)),
        NetLensCallStatusGroup.success,
      );
      expect(
        NetLensCallStatusGroup.of(_call(1, status: 301)),
        NetLensCallStatusGroup.redirection,
      );
      expect(
        NetLensCallStatusGroup.of(_call(1, status: 404)),
        NetLensCallStatusGroup.clientError,
      );
      expect(
        NetLensCallStatusGroup.of(_call(1, status: 503)),
        NetLensCallStatusGroup.serverError,
      );
      expect(
        NetLensCallStatusGroup.of(_call(1, status: -1)),
        NetLensCallStatusGroup.failed,
      );
      expect(
        NetLensCallStatusGroup.of(_call(1, loading: true)),
        NetLensCallStatusGroup.pending,
      );
    });
  });

  group('NetLensCallFilter', () {
    final List<NetLensHttpCall> calls = [
      _call(1),
      _call(2, method: 'POST', status: 500, server: 'auth.example.com'),
      _call(3, status: 404, headers: {'X-Request-Id': 'abc-123'}),
      _call(4, method: 'post', body: {'name': 'Needle'}),
    ];

    List<int> ids(NetLensCallFilter filter) =>
        filter.apply(calls).map((call) => call.id).toList();

    test('passes everything when empty', () {
      expect(ids(const NetLensCallFilter()), [1, 2, 3, 4]);
    });

    test('filters by status group, method and host', () {
      expect(
        ids(
          const NetLensCallFilter(
            statusGroups: {
              NetLensCallStatusGroup.clientError,
              NetLensCallStatusGroup.serverError,
            },
          ),
        ),
        [2, 3],
      );
      expect(ids(const NetLensCallFilter(methods: {'POST'})), [2, 4]);
      expect(ids(const NetLensCallFilter(hosts: {'auth.example.com'})), [2]);
      expect(
        ids(
          const NetLensCallFilter(
            methods: {'POST'},
            statusGroups: {NetLensCallStatusGroup.success},
          ),
        ),
        [4],
      );
    });

    test('searches headers and bodies ignoring case', () {
      expect(ids(const NetLensCallFilter(query: 'ABC-123')), [3]);
      expect(ids(const NetLensCallFilter(query: 'needle')), [4]);
      expect(ids(const NetLensCallFilter(query: '/users/2')), [2]);
      expect(ids(const NetLensCallFilter(query: '404')), [3]);
    });

    test('clears quick filters but keeps the query', () {
      const NetLensCallFilter filter = NetLensCallFilter(
        query: 'a',
        methods: {'GET'},
      );
      expect(filter.clearQuickFilters(), const NetLensCallFilter(query: 'a'));
      expect(filter.hasQuickFilters, true);
      expect(filter.clearQuickFilters().hasQuickFilters, false);
    });
  });
}
