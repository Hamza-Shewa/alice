import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/ui/calls_list/model/netlens_calls_list_sort_option.dart';
import 'package:netlens/ui/calls_list/widget/netlens_call_list_item_widget.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:flutter/material.dart';

/// Widget which displays calls list. It's hosted in tab in calls list page.
class NetLensCallsListScreen extends StatelessWidget {
  const NetLensCallsListScreen({
    super.key,
    required this.calls,
    this.sortOption,
    this.sortAscending = false,
    required this.onListItemClicked,
  });

  final List<NetLensHttpCall> calls;
  final NetLensCallsListSortOption? sortOption;
  final bool sortAscending;
  final void Function(NetLensHttpCall) onListItemClicked;

  static int _compareNullable<T extends Comparable<Object>>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  /// Returns sorted calls based [sortOption] and [sortAscending].
  List<NetLensHttpCall> get _sortedCalls {
    final List<NetLensHttpCall> copy = [...calls];
    final int Function(NetLensHttpCall, NetLensHttpCall)? compare =
        switch (sortOption) {
          NetLensCallsListSortOption.time =>
            (call1, call2) => call1.createdTime.compareTo(call2.createdTime),
          NetLensCallsListSortOption.responseTime =>
            (call1, call2) =>
                _compareNullable(call1.response?.time, call2.response?.time),
          NetLensCallsListSortOption.responseCode =>
            (call1, call2) => _compareNullable(
              call1.response?.status,
              call2.response?.status,
            ),
          NetLensCallsListSortOption.responseSize =>
            (call1, call2) =>
                _compareNullable(call1.response?.size, call2.response?.size),
          NetLensCallsListSortOption.endpoint =>
            (call1, call2) => call1.endpoint.compareTo(call2.endpoint),
          null => null,
        };

    if (compare != null) {
      copy.sort(
        sortAscending ? compare : (call1, call2) => compare(call2, call1),
      );
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    // Sort once per build instead of once per rendered row.
    final List<NetLensHttpCall> sortedCalls = _sortedCalls;
    return ScrollConfiguration(
      behavior: NetLensScrollBehavior(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: sortedCalls.length,
        itemBuilder:
            (_, int index) => NetLensCallListItemWidget(
              sortedCalls[index],
              onListItemClicked,
            ),
      ),
    );
  }
}
