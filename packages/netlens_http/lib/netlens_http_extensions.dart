import 'package:netlens_http/netlens_http_adapter.dart';
import 'package:http/http.dart';

extension NetLensHttpExtensions on Future<Response> {
  /// Intercept http request with netLens. This extension method provides
  /// additional helpful method to intercept https' response.
  Future<Response> interceptWithNetLens(
    NetLensHttpAdapter adapter, {
    dynamic body,
  }) async {
    final response = await this;
    adapter.onResponse(response, body: body);
    return response;
  }
}
