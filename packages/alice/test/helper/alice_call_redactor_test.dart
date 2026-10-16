import 'dart:convert';
import 'dart:io' show Cookie;

import 'package:alice/helper/alice_call_redactor.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_redaction.dart';
import 'package:test/test.dart';

AliceHttpCall _call() =>
    AliceHttpCall(1, createdTime: DateTime(2026))
      ..method = 'POST'
      ..server = 'api.example.com'
      ..endpoint = '/login'
      ..uri = 'https://api.example.com/login?api_key=secret&page=2'
      ..request =
          (AliceHttpRequest()
            ..headers = {'Authorization': 'Bearer abc', 'Accept': 'json'}
            ..cookies = [Cookie('session', 'abc')]
            ..queryParameters = {'api_key': 'secret', 'page': '2'}
            ..formDataFields = [
              const AliceFormDataField('password', 'hunter2'),
              const AliceFormDataField('name', 'alice'),
            ]
            ..body = '{"user":"alice","password":"hunter2"}')
      ..response =
          (AliceHttpResponse()
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
  const AliceCallRedactor redactor = AliceCallRedactor(AliceRedaction());

  group('AliceCallRedactor', () {
    test('masks sensitive values of a copy', () {
      final AliceHttpCall call = _call();
      final AliceHttpCall redacted = redactor.redact(call);

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
        'alice',
      ]);
      expect(jsonDecode(redacted.request!.body as String), {
        'user': 'alice',
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
      final AliceHttpCall call = _call();
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
      const AliceCallRedactor custom = AliceCallRedactor(
        AliceRedaction(headers: {'X-Secret'}, bodyFields: {'PIN'}),
      );
      expect(custom.redactHeaders({'x-secret': 'a', 'authorization': 'b'}), {
        'x-secret': '***',
        'authorization': 'b',
      });
      expect(custom.redactBody({'pin': 1234}), {'pin': '***'});
    });

    test('returns the call itself when redaction is off', () {
      final AliceHttpCall call = _call();
      expect(
        identical(
          const AliceCallRedactor(AliceRedaction.none).redact(call),
          call,
        ),
        true,
      );
    });
  });
}
