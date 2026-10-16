import 'dart:convert';

import 'package:alice/core/alice_adapter.dart';
import 'package:alice/core/alice_call_replayer.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_replay_request.dart';
import 'package:http/http.dart' as http;

class AliceHttpAdapter with AliceAdapter implements AliceCallReplayer {
  AliceHttpAdapter({this.replayClient});

  /// Name of the client shown in Alice.
  static const String clientName = 'HttpClient (http package)';

  /// Client used to send calls again from Alice. When it is null, a new
  /// [http.Client] is used for each replay.
  http.Client? replayClient;

  @override
  bool canReplay(AliceHttpCall call) => call.client == clientName;

  @override
  Future<void> replay(AliceReplayRequest request) async {
    final http.Client client = replayClient ?? http.Client();
    try {
      final http.Request httpRequest = http.Request(
        request.method,
        Uri.parse(request.url),
      )..headers.addAll(request.headers);
      if (request.body != null) {
        httpRequest.body = request.body!;
      }
      final http.Response response = await http.Response.fromStream(
        await client.send(httpRequest),
      );
      onResponse(response);
    } finally {
      if (replayClient == null) {
        client.close();
      }
    }
  }

  /// Handles http response. It creates both request and response from http call
  void onResponse(http.Response response, {dynamic body}) {
    if (response.request == null) {
      return;
    }
    final request = response.request!;

    final call =
        AliceHttpCall(response.request.hashCode)
          ..loading = true
          ..client = clientName
          ..uri = request.url.toString()
          ..method = request.method;
    var path = request.url.path;
    if (path.isEmpty) {
      path = '/';
    }
    call
      ..endpoint = path
      ..server = request.url.host;
    if (request.url.scheme == 'https') {
      call.secure = true;
    }

    final httpRequest = AliceHttpRequest();

    if (response.request is http.Request) {
      // we are guaranteed` the existence of body and headers
      if (body != null) {
        httpRequest.body = body;
      }
      // ignore: cast_nullable_to_non_nullable
      httpRequest
        ..body = body ?? (response.request! as http.Request).body ?? ''
        ..size = utf8.encode(httpRequest.body.toString()).length
        ..headers = Map<String, String>.from(response.request!.headers);
    } else if (body == null) {
      httpRequest
        ..size = 0
        ..body = '';
    } else {
      httpRequest
        ..size = utf8.encode(body.toString()).length
        ..body = body;
    }

    httpRequest.time = DateTime.now();

    String? contentType = 'unknown';
    if (httpRequest.headers.containsKey('Content-Type')) {
      contentType = httpRequest.headers['Content-Type'];
    }

    httpRequest
      ..contentType = contentType
      ..queryParameters = response.request!.url.queryParameters;

    final httpResponse =
        AliceHttpResponse()
          ..status = response.statusCode
          ..body = response.body
          // ignore: noop_primitive_operations
          ..size = utf8.encode(response.body.toString()).length
          ..time = DateTime.now();
    final responseHeaders = <String, String>{};
    response.headers.forEach((header, values) {
      responseHeaders[header] = values;
    });
    httpResponse.headers = responseHeaders;

    call
      ..request = httpRequest
      ..response = httpResponse
      ..loading = false
      ..duration =
          httpResponse.time.millisecondsSinceEpoch -
          httpRequest.time.millisecondsSinceEpoch;
    aliceCore.addCall(call);
  }
}
