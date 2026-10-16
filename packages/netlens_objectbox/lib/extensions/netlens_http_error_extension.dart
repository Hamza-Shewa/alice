import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_error.dart';

/// Extension methods for [NetLensHttpError].
extension NetLensHttpErrorExtension on NetLensHttpError {
  /// Converts [NetLensHttpError] to [CachedNetLensHttpError].
  CachedNetLensHttpError toCached() =>
      CachedNetLensHttpError()
        ..error = error
        ..stackTrace = stackTrace;
}
