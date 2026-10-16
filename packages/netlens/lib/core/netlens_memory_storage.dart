import 'dart:async';

import 'package:netlens/core/netlens_storage.dart';
import 'package:netlens/core/netlens_utils.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/utils/num_comparison.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/subjects.dart';

/// Storage which uses memory to store calls data. It's a default storage
/// method.
class NetLensMemoryStorage implements NetLensStorage {
  NetLensMemoryStorage({required this.maxCallsCount})
    : _callsSubject = BehaviorSubject.seeded([]),
      assert(maxCallsCount > 0, 'Max calls count should be greater than 0');
  @override
  final int maxCallsCount;

  /// Subject which stores all HTTP calls.
  final BehaviorSubject<List<NetLensHttpCall>> _callsSubject;

  /// Stream which returns all HTTP calls on change.
  @override
  Stream<List<NetLensHttpCall>> get callsStream => _callsSubject.stream;

  /// Returns all HTTP calls.
  @override
  List<NetLensHttpCall> getCalls() => _callsSubject.value;

  /// Returns stats based on calls.
  @override
  NetLensStats getStats() {
    final List<NetLensHttpCall> calls = getCalls();

    return (
      total: calls.length,
      successes:
          calls
              .where(
                (NetLensHttpCall call) =>
                    (call.response?.status.gte(200) ?? false) &&
                    (call.response?.status.lt(300) ?? false),
              )
              .length,
      redirects:
          calls
              .where(
                (NetLensHttpCall call) =>
                    (call.response?.status.gte(300) ?? false) &&
                    (call.response?.status.lt(400) ?? false),
              )
              .length,
      errors:
          calls
              .where(
                (NetLensHttpCall call) =>
                    ((call.response?.status.gte(400) ?? false) &&
                        (call.response?.status.lt(600) ?? false)) ||
                    const [-1, 0].contains(call.response?.status),
              )
              .length,
      loading: calls.where((NetLensHttpCall call) => call.loading).length,
    );
  }

  /// Adds new call to calls list.
  @override
  void addCall(NetLensHttpCall call) {
    final int callsCount = _callsSubject.value.length;
    if (callsCount >= maxCallsCount) {
      final List<NetLensHttpCall> originalCalls = _callsSubject.value;
      originalCalls.removeAt(0);
      originalCalls.add(call);

      _callsSubject.add(originalCalls);
    } else {
      _callsSubject.add([..._callsSubject.value, call]);
    }
  }

  /// Adds error to a specific call.
  @override
  void addError(NetLensHttpError error, int requestId) {
    final NetLensHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return NetLensUtils.log('Selected call is null');
    }

    selectedCall.error = error;
    _callsSubject.add([..._callsSubject.value]);
  }

  /// Adds response to a specific call.
  @override
  void addResponse(NetLensHttpResponse response, int requestId) {
    final NetLensHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall == null) {
      return NetLensUtils.log('Selected call is null');
    }

    selectedCall
      ..loading = false
      ..response = response
      ..duration =
          response.time.millisecondsSinceEpoch -
          (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

    _callsSubject.add([..._callsSubject.value]);
  }

  /// Removes all calls.
  @override
  void removeCalls() => _callsSubject.add([]);

  /// Searches for call with specific [requestId]. It may return null.
  @override
  NetLensHttpCall? selectCall(int requestId) => _callsSubject.value
      .firstWhereOrNull((NetLensHttpCall call) => call.id == requestId);
}
