import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_call_filter.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/ui/calls_list/model/netlens_calls_list_sort_option.dart';
import 'package:netlens/ui/calls_list/widget/netlens_call_filter_bar.dart';
import 'package:netlens/ui/calls_list/widget/netlens_calls_list_screen.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_state_widget.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:flutter/material.dart';

/// Screen which is hosted in calls list page. It displays HTTP calls. It allows
/// to search call and sort items based on provided criteria.
class NetLensInspectorScreen extends StatefulWidget {
  const NetLensInspectorScreen({
    super.key,
    required this.netLensCore,
    required this.queryTextEditingController,
    required this.sortOption,
    required this.sortAscending,
    required this.onListItemPressed,
  });

  final NetLensCore netLensCore;
  final TextEditingController queryTextEditingController;
  final NetLensCallsListSortOption sortOption;
  final bool sortAscending;
  final void Function(NetLensHttpCall) onListItemPressed;

  @override
  State<NetLensInspectorScreen> createState() => _NetLensInspectorScreenState();
}

class _NetLensInspectorScreenState extends State<NetLensInspectorScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Quick filters picked in the filter bar. The query comes from the search
  /// field of the page.
  NetLensCallFilter _quickFilters = const NetLensCallFilter();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<NetLensHttpCall>>(
      stream: widget.netLensCore.callsStream,
      initialData: widget.netLensCore.getCalls(),
      builder: (context, AsyncSnapshot<List<NetLensHttpCall>> snapshot) {
        // Copy the list so filtering and sorting never mutate stored calls.
        final List<NetLensHttpCall> allCalls = [...?snapshot.data];
        if (allCalls.isEmpty) {
          return NetLensEmptyStateWidget(
            icon: Icons.wifi_tethering,
            title: context.i18n(NetLensTranslationKey.callsListEmpty),
            description: context.i18n(
              NetLensTranslationKey.callsListEmptyDescription,
            ),
          );
        }
        final String query = widget.queryTextEditingController.text;
        final NetLensCallFilter filter = _quickFilters.copyWith(query: query);
        final List<NetLensHttpCall> calls = filter.apply(allCalls);

        return Column(
          children: [
            NetLensCallFilterBar(
              calls: allCalls,
              filter: _quickFilters,
              onChanged:
                  (NetLensCallFilter value) =>
                      setState(() => _quickFilters = value),
            ),
            Expanded(
              child:
                  calls.isNotEmpty
                      ? NetLensCallsListScreen(
                        calls: calls,
                        sortOption: widget.sortOption,
                        sortAscending: widget.sortAscending,
                        onListItemClicked: widget.onListItemPressed,
                      )
                      : NetLensEmptyStateWidget(
                        icon: Icons.search_off,
                        title:
                            query.trim().isNotEmpty
                                ? context
                                    .i18n(
                                      NetLensTranslationKey.callsListNoResults,
                                    )
                                    .replaceAll('[query]', query)
                                : context.i18n(
                                  NetLensTranslationKey
                                      .callsListNoFilterResults,
                                ),
                      ),
            ),
          ],
        );
      },
    );
  }
}
