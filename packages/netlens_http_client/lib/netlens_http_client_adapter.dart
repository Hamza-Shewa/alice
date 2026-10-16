import 'dart:convert';
import 'dart:io';

import 'package:netlens/core/netlens_adapter.dart';
import 'package:netlens/core/netlens_call_replayer.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:netlens/utils/netlens_parser.dart';

class NetLensHttpClientAdapter
    with NetLensAdapter
    implements NetLensCallReplayer {
  NetLensHttpClientAdapter({this.replayClient});

  /// Name of the client shown in NetLens.
  static const String clientName = 'HttpClient (io package)';

  /// Client used to send calls again from NetLens. When it is null, a new
  /// [HttpClient] is used for each replay.
  HttpClient? replayClient;

  @override
  bool canReplay(NetLensHttpCall call) => call.client == clientName;

  @override
  Future<void> replay(NetLensReplayRequest request) async {
    final HttpClient client = replayClient ?? HttpClient();
    try {
      final HttpClientRequest httpRequest = await client.openUrl(
        request.method,
        Uri.parse(request.url),
      );
      request.headers.forEach(httpRequest.headers.set);
      if (request.body != null) {
        httpRequest.write(request.body);
      }
      onRequest(httpRequest, body: request.body);
      final HttpClientResponse response = await httpRequest.close();
      final String responseBody = await utf8.decoder.bind(response).join();
      await onResponse(response, httpRequest, body: responseBody);
    } finally {
      if (replayClient == null) {
        client.close();
      }
    }
  }

  /// Handles httpClientRequest and creates http netLens call from it
  void onRequest(HttpClientRequest request, {dynamic body}) {
    final call =
        NetLensHttpCall(request.hashCode)
          ..loading = true
          ..client = clientName
          ..method = request.method
          ..uri = request.uri.toString();

    var path = request.uri.path;
    if (path.isEmpty) {
      path = '/';
    }

    call
      ..endpoint = path
      ..server = request.uri.host;
    if (request.uri.scheme == 'https') {
      call.secure = true;
    }
    final httpRequest = NetLensHttpRequest();
    if (body == null) {
      httpRequest
        ..size = 0
        ..body = '';
    } else {
      httpRequest
        ..size = utf8.encode(body.toString()).length
        ..body = body;
    }
    httpRequest.time = DateTime.now();
    final headers = <String, String>{};
    request.headers.forEach((header, values) {
      headers[header] = values.join(', ');
    });

    httpRequest.headers = headers;
    final String contentType =
        NetLensParser.tryGetContentType(headers) ?? 'unknown';

    httpRequest
      ..contentType = contentType
      ..cookies = request.cookies;

    call
      ..request = httpRequest
      ..response = NetLensHttpResponse();
    netLensCore.addCall(call);
  }

  /// Handles httpClientRequest and adds response to http netLens call
  Future<void> onResponse(
    HttpClientResponse response,
    HttpClientRequest request, {
    dynamic body,
  }) async {
    final httpResponse = NetLensHttpResponse()..status = response.statusCode;

    if (body != null) {
      httpResponse
        ..body = body
        ..size = utf8.encode(body.toString()).length;
    } else {
      httpResponse
        ..body = ''
        ..size = 0;
    }
    httpResponse.time = DateTime.now();
    final headers = <String, String>{};
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });
    httpResponse.headers = headers;
    netLensCore.addResponse(httpResponse, request.hashCode);
  }
}
