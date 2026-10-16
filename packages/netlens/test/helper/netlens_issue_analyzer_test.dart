import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/helper/netlens_log_classifier.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_log.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

NetLensHttpCall _call({
  int? status,
  Object? error,
  String uri = 'https://a.com/b',
}) {
  final NetLensHttpCall call =
      NetLensHttpCall(1)
        ..loading = false
        ..uri = uri
        ..server = 'a.com'
        ..endpoint = '/b'
        ..secure = true;
  if (status != null) {
    call.response = NetLensHttpResponse()..status = status;
  }
  if (error != null) {
    call.error = NetLensHttpError()..error = error;
  }
  return call;
}

void main() {
  group('NetLensIssueAnalyzer', () {
    test('successful call has no issue', () {
      expect(NetLensIssueAnalyzer.analyze(_call(status: 200)), isNull);
      expect(NetLensIssueAnalyzer.analyze(_call(status: 304)), isNull);
    });

    test('loading call has no issue', () {
      expect(
        NetLensIssueAnalyzer.analyze(_call(status: 500)..loading = true),
        isNull,
      );
    });

    test('5xx is a backend issue', () {
      final NetLensIssue? issue = NetLensIssueAnalyzer.analyze(
        _call(status: 500),
      );
      expect(issue?.origin, NetLensIssueOrigin.backend);
      expect(issue?.reason, NetLensTranslationKey.issueReasonServerError);
      expect(
        NetLensIssueAnalyzer.analyze(_call(status: 503))?.reason,
        NetLensTranslationKey.issueReasonGateway,
      );
    });

    test('4xx is a frontend issue', () {
      expect(
        NetLensIssueAnalyzer.analyze(_call(status: 400))?.origin,
        NetLensIssueOrigin.frontend,
      );
      expect(
        NetLensIssueAnalyzer.analyze(_call(status: 401))?.reason,
        NetLensTranslationKey.issueReasonAuth,
      );
      expect(
        NetLensIssueAnalyzer.analyze(_call(status: 404))?.reason,
        NetLensTranslationKey.issueReasonNotFound,
      );
    });

    test('408 is a network issue', () {
      expect(
        NetLensIssueAnalyzer.analyze(_call(status: 408))?.origin,
        NetLensIssueOrigin.network,
      );
    });

    test('call without response is a network issue', () {
      expect(
        NetLensIssueAnalyzer.analyze(
          _call(status: -1, error: 'SocketException: Connection refused'),
        )?.origin,
        NetLensIssueOrigin.network,
      );
      expect(
        NetLensIssueAnalyzer.analyze(_call(status: -1))?.origin,
        NetLensIssueOrigin.network,
      );
    });

    test('app failure is a frontend issue', () {
      expect(
        NetLensIssueAnalyzer.analyze(
          _call(status: 200, error: const FormatException('bad json')),
        )?.origin,
        NetLensIssueOrigin.frontend,
      );
    });

    test('malformed url is a frontend issue', () {
      expect(
        NetLensIssueAnalyzer.analyze(
          _call(status: -1, uri: 'http://192.168.1.1:505api/login'),
        )?.reason,
        NetLensTranslationKey.issueReasonMalformedUrl,
      );
    });

    test('malformed url explains a client error', () {
      expect(
        NetLensIssueAnalyzer.analyze(
          _call(status: 404, uri: 'https://a.com/v1login'),
        )?.reason,
        NetLensTranslationKey.issueReasonMalformedUrl,
      );
    });

    test('url which looks wrong does not fail a successful call', () {
      expect(
        NetLensIssueAnalyzer.analyze(
          _call(status: 200, uri: 'https://cdn.a.com/assets//img.png'),
        ),
        isNull,
      );
      expect(
        NetLensIssueAnalyzer.analyze(
          _call(status: 302, uri: 'https://a.com/v1login'),
        ),
        isNull,
      );
    });

    test('url which looks wrong does not hide a server error', () {
      expect(
        NetLensIssueAnalyzer.analyze(
          _call(status: 500, uri: 'https://a.com/v1login'),
        )?.origin,
        NetLensIssueOrigin.backend,
      );
    });
  });

  group('NetLensLogClassifier', () {
    NetLensLogInfo classify(
      String message, {
      DiagnosticLevel? level,
      Object? error,
    }) => NetLensLogClassifier.classify(
      NetLensLog(
        message: message,
        level: level ?? DiagnosticLevel.info,
        error: error,
      ),
    );

    test('detects requests', () {
      final NetLensLogInfo dio = classify('REQUEST[GET] => PATH: /v1/users');
      expect(dio.kind, NetLensLogKind.request);
      expect(dio.method, 'GET');
      expect(dio.url, '/v1/users');

      final NetLensLogInfo okhttp = classify('--> POST https://a.com/login');
      expect(okhttp.kind, NetLensLogKind.request);
      expect(okhttp.method, 'POST');
      expect(okhttp.url, 'https://a.com/login');

      expect(classify('GET https://a.com/x').kind, NetLensLogKind.request);
    });

    test('detects successful responses', () {
      final NetLensLogInfo info = classify('RESPONSE[200] => PATH: /v1/users');
      expect(info.kind, NetLensLogKind.response);
      expect(info.status, 200);
      expect(info.origin, isNull);
      expect(classify('<-- 201 https://a.com').kind, NetLensLogKind.response);
      expect(classify('statusCode: 204').status, 204);
    });

    test('detects failed responses and their origin', () {
      final NetLensLogInfo server = classify('RESPONSE[503] => PATH: /x');
      expect(server.kind, NetLensLogKind.error);
      expect(server.origin, NetLensIssueOrigin.backend);

      final NetLensLogInfo client = classify('<-- 404 https://a.com/x');
      expect(client.kind, NetLensLogKind.error);
      expect(client.origin, NetLensIssueOrigin.frontend);

      final NetLensLogInfo dio = classify('ERROR[401] => PATH: /x');
      expect(dio.kind, NetLensLogKind.error);
      expect(dio.status, 401);
    });

    test('detects errors', () {
      expect(
        classify('Something', level: DiagnosticLevel.error).kind,
        NetLensLogKind.error,
      );
      expect(classify('Login failed').kind, NetLensLogKind.error);
      expect(classify('ok', error: Exception('x')).kind, NetLensLogKind.error);
      expect(
        classify('SocketException: connection refused').origin,
        NetLensIssueOrigin.network,
      );
    });

    test('detects warnings and plain info', () {
      expect(
        classify('Low disk', level: DiagnosticLevel.warning).kind,
        NetLensLogKind.warning,
      );
      expect(classify('User opened screen').kind, NetLensLogKind.info);
    });
  });
}
