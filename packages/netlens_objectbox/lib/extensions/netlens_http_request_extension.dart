import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_request.dart';

/// Extension methods for [NetLensHttpRequest].
extension NetLensHttpRequestExtension on NetLensHttpRequest {
  /// Converts [NetLensHttpRequest] to [CachedNetLensHttpRequest].
  CachedNetLensHttpRequest toCached() => CachedNetLensHttpRequest(
    size: size,
    time: time,
    headers: headers,
    body: body,
    contentType: contentType,
    cookies: cookies,
    queryParameters: queryParameters,
    formDataFiles: formDataFiles,
    formDataFields: formDataFields,
  );
}
