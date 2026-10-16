import 'package:netlens/model/netlens_http_call.dart';
import 'dart:async' show FutureOr;

import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_response.dart';

/// Definition of call stats.
typedef NetLensStats =
    ({int total, int successes, int redirects, int errors, int loading});

/// Definition of storage
abstract interface class NetLensStorage {
  /// Stream which returns all HTTP calls on change.
  abstract final Stream<List<NetLensHttpCall>> callsStream;

  /// Max calls number which should be stored.
  abstract final int maxCallsCount;

  /// Returns all HTTP calls.
  List<NetLensHttpCall> getCalls();

  /// Returns stats based on calls.
  NetLensStats getStats();

  /// Searches for call with specific [requestId]. It may return null.
  NetLensHttpCall? selectCall(int requestId);

  /// Adds new call to calls list.
  FutureOr<void> addCall(NetLensHttpCall call);

  /// Adds error to a specific call.
  FutureOr<void> addError(NetLensHttpError error, int requestId);

  /// Adds response to a specific call.
  FutureOr<void> addResponse(NetLensHttpResponse response, int requestId);

  /// Removes all calls.
  FutureOr<void> removeCalls();
}
