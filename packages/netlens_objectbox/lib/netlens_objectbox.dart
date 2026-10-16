import 'dart:math' show max;

import 'package:netlens/core/netlens_storage.dart';
import 'package:netlens/core/netlens_utils.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens_objectbox/netlens_objectbox_store.dart';
import 'package:netlens_objectbox/extensions/netlens_http_call_extension.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_call.dart';
import 'package:netlens_objectbox/objectbox.g.dart';

export 'package:netlens_objectbox/netlens_objectbox_store.dart';

/// Implementation of [NetLensStorage] using ObjectBox.
class NetLensObjectBox implements NetLensStorage {
  const NetLensObjectBox({
    required NetLensObjectBoxStore store,
    required this.maxCallsCount,
  }) : _store = store,
       assert(maxCallsCount > 0, 'Max calls count should be greater than 0');

  final NetLensObjectBoxStore _store;

  @override
  final int maxCallsCount;

  @override
  Stream<List<NetLensHttpCall>> get callsStream =>
      _store.httpCalls
          .query()
          .order<int>(
            CachedNetLensHttpCall_.createdTime,
            flags: Order.descending,
          )
          .watch(triggerImmediately: true)
          .map((Query<CachedNetLensHttpCall> query) => query.find())
          .asBroadcastStream();

  @override
  List<NetLensHttpCall> getCalls() => _store.httpCalls.getAll();

  @override
  CachedNetLensHttpCall? selectCall(int requestId) =>
      _store.httpCalls
          .query(CachedNetLensHttpCall_.id.equals(requestId))
          .build()
          .findFirst();

  Future<void> _removeOverQuota() async {
    if (maxCallsCount > 0 && _store.httpCalls.count() >= maxCallsCount) {
      final Query<CachedNetLensHttpCall> overQuota =
          _store.httpCalls
              .query()
              .order<int>(
                CachedNetLensHttpCall_.createdTime,
                flags: Order.descending,
              )
              .build()
            ..offset = max(maxCallsCount - 1, 0);

      final List<int> overQuotaIds = await overQuota.findIdsAsync();

      if (overQuotaIds.isNotEmpty) {
        _store.httpCalls.removeManyAsync(overQuotaIds);
      }
    }
  }

  @override
  void addCall(NetLensHttpCall call) {
    _removeOverQuota();

    _store.httpCalls.put(call.toCached());
  }

  @override
  void addError(NetLensHttpError error, int requestId) {
    final CachedNetLensHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall != null) {
      selectedCall.error = error;

      _store.httpCalls.put(selectedCall);
    } else {
      NetLensUtils.log('Selected call is null');
    }
  }

  @override
  void addResponse(NetLensHttpResponse response, int requestId) {
    final CachedNetLensHttpCall? selectedCall = selectCall(requestId);

    if (selectedCall != null) {
      selectedCall
        ..loading = false
        ..response = response
        ..duration =
            response.time.millisecondsSinceEpoch -
            (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

      _store.httpCalls.put(selectedCall);
    } else {
      NetLensUtils.log('Selected call is null');
    }
  }

  @override
  Future<void> removeCalls() => _store.httpCalls.removeAllAsync();

  @override
  NetLensStats getStats() => (
    total: _store.httpCalls.count(),
    successes:
        (_store.httpCalls.query()..link(
              CachedNetLensHttpCall_.responseRel,
              CachedNetLensHttpResponse_.status
                  .greaterOrEqual(200)
                  .and(CachedNetLensHttpResponse_.status.lessThan(300)),
            ))
            .build()
            .count(),
    redirects:
        (_store.httpCalls.query()..link(
              CachedNetLensHttpCall_.responseRel,
              CachedNetLensHttpResponse_.status
                  .greaterOrEqual(300)
                  .and(CachedNetLensHttpResponse_.status.lessThan(400)),
            ))
            .build()
            .count(),
    errors:
        (_store.httpCalls.query()..link(
              CachedNetLensHttpCall_.responseRel,
              CachedNetLensHttpResponse_.status
                  .greaterOrEqual(400)
                  .and(CachedNetLensHttpResponse_.status.lessThan(600))
                  .and(CachedNetLensHttpResponse_.status.equals(-1))
                  .and(CachedNetLensHttpResponse_.status.equals(0)),
            ))
            .build()
            .count(),
    loading:
        _store.httpCalls
            .query(CachedNetLensHttpCall_.loading.equals(true))
            .build()
            .count(),
  );
}
