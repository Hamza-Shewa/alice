import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:netlens_http_client/netlens_http_client_adapter.dart';

extension NetLensHttpClientExtensions on Future<HttpClientRequest> {
  /// Intercept http client with netLens. This extension method provides
  /// additional helpful method to intercept httpClientResponse.
  Future<HttpClientResponse> interceptWithNetLens(
    NetLensHttpClientAdapter netLens, {
    dynamic body,
    Map<String, dynamic>? headers,
  }) async {
    final request = await this;
    if (body != null) {
      request.write(body);
    }
    if (headers != null) {
      headers.forEach((String key, dynamic value) {
        request.headers.add(key, value as Object);
      });
    }
    netLens.onRequest(request, body: body);
    final httpResponse = await request.close();
    final responseBody = await utf8.decoder.bind(httpResponse).join();
    netLens.onResponse(httpResponse, request, body: responseBody);
    return httpResponse;
  }
}
