import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:alice/ui/calls_list/widget/alice_calls_list_screen.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_state_widget.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:flutter/material.dart';

/// Screen which is hosted in calls list page. It displays HTTP calls. It allows
/// to search call and sort items based on provided criteria.
class AliceInspectorScreen extends StatefulWidget {
  const AliceInspectorScreen({
    super.key,
    required this.aliceCore,
    required this.queryTextEditingController,
    required this.sortOption,
    required this.sortAscending,
    required this.onListItemPressed,
  });

  final AliceCore aliceCore;
  final TextEditingController queryTextEditingController;
  final AliceCallsListSortOption sortOption;
  final bool sortAscending;
  final void Function(AliceHttpCall) onListItemPressed;

  @override
  State<AliceInspectorScreen> createState() => _AliceInspectorScreenState();
}

class _AliceInspectorScreenState extends State<AliceInspectorScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<AliceHttpCall>>(
      stream: widget.aliceCore.callsStream,
      builder: (context, AsyncSnapshot<List<AliceHttpCall>> snapshot) {
        // Copy the list so filtering and sorting never mutate stored calls.
        final List<AliceHttpCall> allCalls = [...?snapshot.data];
        final String query =
            widget.queryTextEditingController.text.trim().toLowerCase();
        final List<AliceHttpCall> calls =
            query.isEmpty
                ? allCalls
                : allCalls.where((call) => _matches(call, query)).toList();

        if (calls.isNotEmpty) {
          return AliceCallsListScreen(
            calls: calls,
            sortOption: widget.sortOption,
            sortAscending: widget.sortAscending,
            onListItemClicked: widget.onListItemPressed,
          );
        }
        if (query.isNotEmpty) {
          return AliceEmptyStateWidget(
            icon: Icons.search_off,
            title: context
                .i18n(AliceTranslationKey.callsListNoResults)
                .replaceAll('[query]', widget.queryTextEditingController.text),
          );
        }
        return AliceEmptyStateWidget(
          icon: Icons.wifi_tethering,
          title: context.i18n(AliceTranslationKey.callsListEmpty),
          description: context.i18n(
            AliceTranslationKey.callsListEmptyDescription,
          ),
        );
      },
    );
  }

  /// Returns true when [call] endpoint, server, method or status contains
  /// lowercase [query].
  bool _matches(AliceHttpCall call, String query) =>
      call.endpoint.toLowerCase().contains(query) ||
      call.server.toLowerCase().contains(query) ||
      call.method.toLowerCase().contains(query) ||
      (call.response?.status?.toString().contains(query) ?? false);
}
