import 'package:netlens/helper/netlens_call_statistics.dart';
import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:flutter_test/flutter_test.dart';

NetLensHttpCall _call(
  int id, {
  int? status,
  int duration = 0,
  String method = 'GET',
  bool secure = true,
  bool loading = false,
  int sent = 0,
  int received = 0,
  dynamic body,
}) {
  final NetLensHttpCall call =
      NetLensHttpCall(id)
        ..method = method
        ..secure = secure
        ..loading = loading
        ..duration = duration
        ..uri = 'https://a.com/b'
        ..server = 'a.com'
        ..endpoint = '/b'
        ..request = (NetLensHttpRequest()..size = sent);
  if (status != null) {
    call.response =
        NetLensHttpResponse()
          ..status = status
          ..size = received
          ..body = body;
  }
  return call;
}

void main() {
  setUp(() => NetLensWatcher.instance.reset());

  test('counts calls by status and method', () {
    final NetLensCallStatistics stats = NetLensCallStatistics.from([
      _call(1, status: 200),
      _call(2, status: 201, method: 'POST'),
      _call(3, status: 301),
      _call(4, status: 404),
      _call(5, status: 500, method: 'POST'),
      _call(6, status: -1, secure: false),
      _call(7, loading: true),
    ]);

    expect(stats.total, 7);
    expect(stats.pending, 1);
    expect(stats.success, 2);
    expect(stats.redirection, 1);
    expect(stats.error, 3);
    expect(stats.methods, {'GET': 5, 'POST': 2});
    expect(stats.secured, 6);
    expect(stats.unsecured, 1);
    expect(stats.successRate, 33);
  });

  test('sums bytes and calculates durations', () {
    final NetLensCallStatistics stats = NetLensCallStatistics.from([
      _call(1, status: 200, duration: 100, sent: 10, received: 1000),
      _call(2, status: 200, duration: 300, sent: 20, received: 2000),
      _call(3, status: 200, duration: 200),
      _call(4, status: 200),
    ]);

    expect(stats.bytesSent, 30);
    expect(stats.bytesReceived, 3000);
    // Calls without a duration are ignored; the average is not the last
    // duration (the old implementation returned 200 ~/ 3).
    expect(stats.averageTime, 200);
    expect(stats.maxTime, 300);
    expect(stats.minTime, 100);
  });

  test('has zeros and no success rate without calls', () {
    final NetLensCallStatistics stats = NetLensCallStatistics.from([]);

    expect(stats.total, 0);
    expect(stats.averageTime, 0);
    expect(stats.minTime, 0);
    expect(stats.successRate, isNull);
    expect(stats.issueCount, 0);
  });

  test('groups failures by side, including the watched field', () {
    final NetLensCallStatistics stats = NetLensCallStatistics.from([
      _call(1, status: 200),
      _call(2, status: 404),
      _call(3, status: 422),
      _call(4, status: 503),
      _call(5, status: -1),
      // HTTP 200, but the watched `type` field says that it failed.
      _call(6, status: 200, body: {'type': 2}),
    ]);

    expect(stats.issues, {
      NetLensIssueOrigin.frontend: 3,
      NetLensIssueOrigin.backend: 1,
      NetLensIssueOrigin.network: 1,
    });
    expect(stats.issueCount, 5);
  });
}
