import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:alice/ui/calls_list/widget/alice_call_list_item_widget.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:flutter/material.dart';

/// Widget which displays calls list. It's hosted in tab in calls list page.
class AliceCallsListScreen extends StatelessWidget {
  const AliceCallsListScreen({
    super.key,
    required this.calls,
    this.sortOption,
    this.sortAscending = false,
    required this.onListItemClicked,
  });

  final List<AliceHttpCall> calls;
  final AliceCallsListSortOption? sortOption;
  final bool sortAscending;
  final void Function(AliceHttpCall) onListItemClicked;

  static int _compareNullable<T extends Comparable<Object>>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  /// Returns sorted calls based [sortOption] and [sortAscending].
  List<AliceHttpCall> get _sortedCalls {
    final List<AliceHttpCall> copy = [...calls];
    final int Function(AliceHttpCall, AliceHttpCall)? compare =
        switch (sortOption) {
          AliceCallsListSortOption.time =>
            (call1, call2) => call1.createdTime.compareTo(call2.createdTime),
          AliceCallsListSortOption.responseTime =>
            (call1, call2) =>
                _compareNullable(call1.response?.time, call2.response?.time),
          AliceCallsListSortOption.responseCode =>
            (call1, call2) => _compareNullable(
              call1.response?.status,
              call2.response?.status,
            ),
          AliceCallsListSortOption.responseSize =>
            (call1, call2) =>
                _compareNullable(call1.response?.size, call2.response?.size),
          AliceCallsListSortOption.endpoint =>
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
    final List<AliceHttpCall> sortedCalls = _sortedCalls;
    return ScrollConfiguration(
      behavior: AliceScrollBehavior(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: sortedCalls.length,
        itemBuilder:
            (_, int index) =>
                AliceCallListItemWidget(sortedCalls[index], onListItemClicked),
      ),
    );
  }
}
