import 'dart:convert';

import 'package:netlens/helper/netlens_har_builder.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:test/test.dart';

NetLensHttpCall _call(int id, DateTime time) =>
    NetLensHttpCall(id)
      ..method = 'post'
      ..server = 'api.example.com'
      ..endpoint = '/items'
      ..uri = 'https://api.example.com/items?page=2'
      ..secure = true
      ..loading = false
      ..duration = 120
      ..request =
          (NetLensHttpRequest()
            ..time = time
            ..size = 12
            ..contentType = 'application/json'
            ..headers = {'Accept': 'application/json'}
            ..body = {'name': 'a'})
      ..response =
          (NetLensHttpResponse()
            ..status = 201
            ..size = 9
            ..headers = {'content-type': 'application/json'}
            ..body = '{"id": 2}');

void main() {
  group('NetLensHarBuilder', () {
    test('builds a HAR 1.2 log sorted by start time', () {
      final Map<String, dynamic> har = NetLensHarBuilder.build([
        _call(2, DateTime.utc(2026, 1, 1, 10, 0, 5)),
        _call(1, DateTime.utc(2026, 1, 1, 10)),
      ], creatorVersion: '1.0.0');

      final Map<String, dynamic> log = har['log'];
      expect(log['version'], '1.2');
      expect(log['creator'], {'name': 'NetLens', 'version': '1.0.0'});
      final List<dynamic> entries = log['entries'];
      expect(entries.map((entry) => entry['startedDateTime']), [
        '2026-01-01T10:00:00.000Z',
        '2026-01-01T10:00:05.000Z',
      ]);
    });

    test('maps request and response of a call', () {
      final Map<String, dynamic> entry = NetLensHarBuilder.buildEntry(
        _call(1, DateTime.utc(2026)),
      );
      expect(entry['time'], 120);
      expect(entry['request']['method'], 'POST');
      expect(entry['request']['url'], 'https://api.example.com/items?page=2');
      expect(entry['request']['headers'], [
        {'name': 'Accept', 'value': 'application/json'},
      ]);
      expect(entry['request']['queryString'], [
        {'name': 'page', 'value': '2'},
      ]);
      expect(entry['request']['postData'], {
        'mimeType': 'application/json',
        'text': '{"name":"a"}',
      });
      expect(entry['response']['status'], 201);
      expect(entry['response']['statusText'], 'Created');
      expect(entry['response']['content'], {
        'size': 9,
        'mimeType': 'application/json',
        'text': '{"id": 2}',
      });
    });

    test('reports failed calls with status 0 and the error', () {
      final NetLensHttpCall call =
          _call(1, DateTime.utc(2026))
            ..response = (NetLensHttpResponse()..status = -1)
            ..error = (NetLensHttpError()..error = 'SocketException');
      final Map<String, dynamic> entry = NetLensHarBuilder.buildEntry(call);
      expect(entry['response']['status'], 0);
      expect(entry['comment'], 'SocketException');
    });

    test('encodes valid JSON', () {
      final String har = NetLensHarBuilder.encode([_call(1, DateTime(2026))]);
      expect(() => jsonDecode(har), returnsNormally);
    });
  });
}
