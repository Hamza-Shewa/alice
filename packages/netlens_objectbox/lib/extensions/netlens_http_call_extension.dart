import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_call.dart';

/// Extension methods for [NetLensHttpCall].
extension NetLensHttpCallExtension on NetLensHttpCall {
  /// Converts [NetLensHttpCall] to [CachedNetLensHttpCall].
  CachedNetLensHttpCall toCached() =>
      CachedNetLensHttpCall(
          id,
          client: client,
          loading: loading,
          secure: secure,
          method: method,
          endpoint: endpoint,
          server: server,
          uri: uri,
          duration: duration,
        )
        ..error = error
        ..request = request
        ..response = response;
}
