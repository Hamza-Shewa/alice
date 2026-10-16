import 'dart:convert';
import 'dart:io' show Cookie;

import 'package:netlens/helper/netlens_call_redactor.dart';
import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_redaction.dart';
import 'package:test/test.dart';

NetLensHttpCall _call() =>
    NetLensHttpCall(1, createdTime: DateTime(2026))
      ..method = 'POST'
      ..server = 'api.example.com'
      ..endpoint = '/login'
      ..uri = 'https://api.example.com/login?api_key=secret&page=2'
      ..request =
          (NetLensHttpRequest()
            ..headers = {'Authorization': 'Bearer abc', 'Accept': 'json'}
            ..cookies = [Cookie('session', 'abc')]
            ..queryParameters = {'api_key': 'secret', 'page': '2'}
            ..formDataFields = [
              const NetLensFormDataField('password', 'hunter2'),
              const NetLensFormDataField('name', 'netLens'),
            ]
            ..body = '{"user":"netLens","password":"hunter2"}')
      ..response =
          (NetLensHttpResponse()
            ..status = 200
            ..headers = {'set-cookie': 'session=abc', 'content-type': 'json'}
            ..body = {
              'data': {
                'access_token': 'xyz',
                'items': [
                  {'token': 't', 'id': 1},
                ],
              },
            });

void main() {
  const NetLensCallRedactor redactor = NetLensCallRedactor(NetLensRedaction());

  group('NetLensCallRedactor', () {
    test('masks sensitive values of a copy', () {
      final NetLensHttpCall call = _call();
      final NetLensHttpCall redacted = redactor.redact(call);

      expect(redacted.request!.headers, {
        'Authorization': '***',
        'Accept': 'json',
      });
      expect(redacted.request!.cookies.single.value, '***');
      expect(redacted.request!.queryParameters, {
        'api_key': '***',
        'page': '2',
      });
      expect(redacted.request!.formDataFields!.map((field) => field.value), [
        '***',
        'netLens',
      ]);
      expect(jsonDecode(redacted.request!.body as String), {
        'user': 'netLens',
        'password': '***',
      });
      expect(redacted.response!.headers!['set-cookie'], '***');
      expect(redacted.response!.body, {
        'data': {
          'access_token': '***',
          'items': [
            {'token': '***', 'id': 1},
          ],
        },
      });
      expect(Uri.parse(redacted.uri).queryParameters, {
        'api_key': '***',
        'page': '2',
      });
      expect(redacted.createdTime, call.createdTime);
    });

    test('does not change the original call', () {
      final NetLensHttpCall call = _call();
      redactor.redact(call);

      expect(call.request!.headers['Authorization'], 'Bearer abc');
      expect(call.request!.body, contains('hunter2'));
      expect((call.response!.body as Map)['data']['access_token'], 'xyz');
    });

    test('keeps bodies which are not JSON or have no sensitive field', () {
      expect(redactor.redactBody('password=1'), 'password=1');
      const String body = '{"name": "a"}';
      expect(identical(redactor.redactBody(body), body), true);
    });

    test('matches names ignoring case and allows custom names', () {
      const NetLensCallRedactor custom = NetLensCallRedactor(
        NetLensRedaction(headers: {'X-Secret'}, bodyFields: {'PIN'}),
      );
      expect(custom.redactHeaders({'x-secret': 'a', 'authorization': 'b'}), {
        'x-secret': '***',
        'authorization': 'b',
      });
      expect(custom.redactBody({'pin': 1234}), {'pin': '***'});
    });

    test('returns the call itself when redaction is off', () {
      final NetLensHttpCall call = _call();
      expect(
        identical(
          const NetLensCallRedactor(NetLensRedaction.none).redact(call),
          call,
        ),
        true,
      );
    });
  });
}
