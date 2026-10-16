import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_response.dart';

/// Extension methods for [NetLensHttpResponse].
extension NetLensHttpResponseExtension on NetLensHttpResponse {
  /// Converts [NetLensHttpResponse] to [CachedNetLensHttpResponse].
  CachedNetLensHttpResponse toCached() => CachedNetLensHttpResponse(
    status: status,
    size: size,
    time: time,
    body: body,
    headers: headers,
  );
}
