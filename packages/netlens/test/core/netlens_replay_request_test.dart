import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:test/test.dart';

void main() {
  group('NetLensReplayRequest', () {
    test('is built from a call', () {
      final NetLensReplayRequest request = NetLensReplayRequest.fromCall(
        NetLensHttpCall(1)
          ..method = 'post'
          ..uri = 'https://api.example.com/items?page=1'
          ..request =
              (NetLensHttpRequest()
                ..headers = {
                  'content-type': 'application/json',
                  'Content-Length': '12',
                  'Host': 'api.example.com',
                }
                ..body = {'name': 'a'}),
      );
      expect(request.method, 'POST');
      expect(request.url, 'https://api.example.com/items?page=1');
      expect(request.headers, {'content-type': 'application/json'});
      expect(request.body, '{"name":"a"}');
      expect(request.omitsFormData, false);
    });

    test('builds the URL from server, endpoint and query parameters', () {
      final NetLensReplayRequest request = NetLensReplayRequest.fromCall(
        NetLensHttpCall(1)
          ..method = 'GET'
          ..secure = true
          ..server = 'api.example.com'
          ..endpoint = '/items'
          ..request = (NetLensHttpRequest()..queryParameters = {'page': 2}),
      );
      expect(request.url, 'https://api.example.com/items?page=2');
      expect(request.hasBody, false);
    });

    test('leaves out form data which NetLens did not keep', () {
      final NetLensReplayRequest request = NetLensReplayRequest.fromCall(
        NetLensHttpCall(1)
          ..method = 'POST'
          ..uri = 'https://api.example.com/upload'
          ..request =
              (NetLensHttpRequest()
                ..body = 'Form data'
                ..formDataFields = [const NetLensFormDataField('a', 'b')]),
      );
      expect(request.body, null);
      expect(request.omitsFormData, true);
    });

    test('converts headers to and from text', () {
      expect(
        NetLensReplayRequest.headersToText({'Accept': 'json', 'X-Id': '1'}),
        'Accept: json\nX-Id: 1',
      );
      final parsed = NetLensReplayRequest.parseHeaders(
        'Accept: json\n\n X-Url: http://a ',
      );
      expect(parsed.headers, {'Accept': 'json', 'X-Url': 'http://a'});
      expect(parsed.invalidLine, null);
      expect(
        NetLensReplayRequest.parseHeaders('Accept: json\nbroken').invalidLine,
        2,
      );
    });
  });
}
