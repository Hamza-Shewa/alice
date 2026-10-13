import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/helper/alice_log_classifier.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

AliceHttpCall _call({
  int? status,
  Object? error,
  String uri = 'https://a.com/b',
}) {
  final AliceHttpCall call =
      AliceHttpCall(1)
        ..loading = false
        ..uri = uri
        ..server = 'a.com'
        ..endpoint = '/b'
        ..secure = true;
  if (status != null) {
    call.response = AliceHttpResponse()..status = status;
  }
  if (error != null) {
    call.error = AliceHttpError()..error = error;
  }
  return call;
}

void main() {
  group('AliceIssueAnalyzer', () {
    test('successful call has no issue', () {
      expect(AliceIssueAnalyzer.analyze(_call(status: 200)), isNull);
      expect(AliceIssueAnalyzer.analyze(_call(status: 304)), isNull);
    });

    test('loading call has no issue', () {
      expect(
        AliceIssueAnalyzer.analyze(_call(status: 500)..loading = true),
        isNull,
      );
    });

    test('5xx is a backend issue', () {
      final AliceIssue? issue = AliceIssueAnalyzer.analyze(_call(status: 500));
      expect(issue?.origin, AliceIssueOrigin.backend);
      expect(issue?.reason, AliceTranslationKey.issueReasonServerError);
      expect(
        AliceIssueAnalyzer.analyze(_call(status: 503))?.reason,
        AliceTranslationKey.issueReasonGateway,
      );
    });

    test('4xx is a frontend issue', () {
      expect(
        AliceIssueAnalyzer.analyze(_call(status: 400))?.origin,
        AliceIssueOrigin.frontend,
      );
      expect(
        AliceIssueAnalyzer.analyze(_call(status: 401))?.reason,
        AliceTranslationKey.issueReasonAuth,
      );
      expect(
        AliceIssueAnalyzer.analyze(_call(status: 404))?.reason,
        AliceTranslationKey.issueReasonNotFound,
      );
    });

    test('408 is a network issue', () {
      expect(
        AliceIssueAnalyzer.analyze(_call(status: 408))?.origin,
        AliceIssueOrigin.network,
      );
    });

    test('call without response is a network issue', () {
      expect(
        AliceIssueAnalyzer.analyze(
          _call(status: -1, error: 'SocketException: Connection refused'),
        )?.origin,
        AliceIssueOrigin.network,
      );
      expect(
        AliceIssueAnalyzer.analyze(_call(status: -1))?.origin,
        AliceIssueOrigin.network,
      );
    });

    test('app failure is a frontend issue', () {
      expect(
        AliceIssueAnalyzer.analyze(
          _call(status: 200, error: const FormatException('bad json')),
        )?.origin,
        AliceIssueOrigin.frontend,
      );
    });

    test('malformed url is a frontend issue', () {
      expect(
        AliceIssueAnalyzer.analyze(
          _call(status: -1, uri: 'http://192.168.1.1:505api/login'),
        )?.reason,
        AliceTranslationKey.issueReasonMalformedUrl,
      );
    });
  });

  group('AliceLogClassifier', () {
    AliceLogInfo classify(
      String message, {
      DiagnosticLevel? level,
      Object? error,
    }) => AliceLogClassifier.classify(
      AliceLog(
        message: message,
        level: level ?? DiagnosticLevel.info,
        error: error,
      ),
    );

    test('detects requests', () {
      final AliceLogInfo dio = classify('REQUEST[GET] => PATH: /v1/users');
      expect(dio.kind, AliceLogKind.request);
      expect(dio.method, 'GET');
      expect(dio.url, '/v1/users');

      final AliceLogInfo okhttp = classify('--> POST https://a.com/login');
      expect(okhttp.kind, AliceLogKind.request);
      expect(okhttp.method, 'POST');
      expect(okhttp.url, 'https://a.com/login');

      expect(classify('GET https://a.com/x').kind, AliceLogKind.request);
    });

    test('detects successful responses', () {
      final AliceLogInfo info = classify('RESPONSE[200] => PATH: /v1/users');
      expect(info.kind, AliceLogKind.response);
      expect(info.status, 200);
      expect(info.origin, isNull);
      expect(classify('<-- 201 https://a.com').kind, AliceLogKind.response);
      expect(classify('statusCode: 204').status, 204);
    });

    test('detects failed responses and their origin', () {
      final AliceLogInfo server = classify('RESPONSE[503] => PATH: /x');
      expect(server.kind, AliceLogKind.error);
      expect(server.origin, AliceIssueOrigin.backend);

      final AliceLogInfo client = classify('<-- 404 https://a.com/x');
      expect(client.kind, AliceLogKind.error);
      expect(client.origin, AliceIssueOrigin.frontend);

      final AliceLogInfo dio = classify('ERROR[401] => PATH: /x');
      expect(dio.kind, AliceLogKind.error);
      expect(dio.status, 401);
    });

    test('detects errors', () {
      expect(
        classify('Something', level: DiagnosticLevel.error).kind,
        AliceLogKind.error,
      );
      expect(classify('Login failed').kind, AliceLogKind.error);
      expect(classify('ok', error: Exception('x')).kind, AliceLogKind.error);
      expect(
        classify('SocketException: connection refused').origin,
        AliceIssueOrigin.network,
      );
    });

    test('detects warnings and plain info', () {
      expect(
        classify('Low disk', level: DiagnosticLevel.warning).kind,
        AliceLogKind.warning,
      );
      expect(classify('User opened screen').kind, AliceLogKind.info);
    });
  });
}
