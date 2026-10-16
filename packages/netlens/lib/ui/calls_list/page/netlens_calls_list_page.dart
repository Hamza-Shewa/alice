// ignore_for_file: use_build_context_synchronously

import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/operating_system.dart';
import 'package:netlens/model/netlens_export_result.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/call_details/model/netlens_menu_item.dart';
import 'package:netlens/ui/calls_list/model/netlens_calls_list_sort_option.dart';
import 'package:netlens/ui/calls_list/model/netlens_calls_list_tab_item.dart';
import 'package:netlens/ui/calls_list/widget/netlens_inspector_screen.dart';
import 'package:netlens/ui/calls_list/widget/netlens_logs_screen.dart';
import 'package:netlens/ui/calls_list/widget/netlens_sort_dialog.dart';
import 'package:netlens/ui/common/netlens_app_bar.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_dialog.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';
import 'package:netlens/ui/common/netlens_page.dart';
import 'package:netlens/ui/common/netlens_settings.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

/// Page which displays list of calls caught by NetLens. It displays tab view
/// where calls and logs can be inspected. It allows to sort calls, delete calls
/// and search calls.
class NetLensCallsListPage extends StatefulWidget {
  final NetLensCore core;

  const NetLensCallsListPage({required this.core, super.key});

  @override
  State<NetLensCallsListPage> createState() => _NetLensCallsListPageState();
}

class _NetLensCallsListPageState extends State<NetLensCallsListPage>
    with SingleTickerProviderStateMixin, NetLensSettingsListenerMixin {
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  final List<NetLensCallsListTabItem> _tabItems =
      NetLensCallsListTabItem.values;
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;

  NetLensCallsListSortOption _sortOption = NetLensCallsListSortOption.time;
  bool _sortAscending = false;
  bool _searchEnabled = false;
  bool isAndroidRawLogsEnabled = false;
  int _selectedIndex = 0;

  NetLensCore get netLensCore => widget.core;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: _tabItems.length,
      initialIndex: _tabItems.first.index,
    );

    _tabController.addListener(() {
      if (mounted && _selectedIndex != _tabController.index) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _queryTextEditingController.dispose();
    _tabController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  /// Returns [true] when logger tab is opened.
  bool get isLoggerTab => _selectedIndex == 1;

  @override
  Widget build(BuildContext context) {
    return NetLensPage(
      core: netLensCore,
      child: Scaffold(
        appBar: NetLensAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _onBackPressed,
          ),
          title:
              _searchEnabled
                  ? _SearchTextField(
                    textEditingController: _queryTextEditingController,
                    onChanged: _updateSearchQuery,
                    onClearPressed: _onClearSearchPressed,
                  )
                  : Text(context.i18n(NetLensTranslationKey.netLens)),
          actions:
              isLoggerTab
                  ? <Widget>[
                    NetLensSettingsButton(core: widget.core),
                    if (OperatingSystem.isAndroid)
                      IconButton(
                        icon: const Icon(Icons.terminal),
                        tooltip: context.i18n(
                          NetLensTranslationKey.callsListRawLogs,
                        ),
                        isSelected: isAndroidRawLogsEnabled,
                        onPressed: _onLogsChangePressed,
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: context.i18n(
                        NetLensTranslationKey.callsListDelete,
                      ),
                      onPressed: _onClearLogsPressed,
                    ),
                  ]
                  : <Widget>[
                    NetLensSettingsButton(core: widget.core),
                    IconButton(
                      icon: Icon(_searchEnabled ? Icons.close : Icons.search),
                      tooltip:
                          _searchEnabled
                              ? MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip
                              : context.i18n(
                                NetLensTranslationKey.callsListSearch,
                              ),
                      onPressed: _onSearchPressed,
                    ),
                    _ContextMenuButton(onMenuItemSelected: _onMenuItemSelected),
                  ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: NetLensTheme.lightRed,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            tabs:
                NetLensCallsListTabItem.values.map((item) {
                  return Tab(text: _getTabName(item: item));
                }).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            NetLensInspectorScreen(
              netLensCore: netLensCore,
              queryTextEditingController: _queryTextEditingController,
              sortOption: _sortOption,
              sortAscending: _sortAscending,
              onListItemPressed: _onListItemPressed,
            ),
            NetLensLogsScreen(
              scrollController: _scrollController,
              netLensLogger: widget.core.configuration.netLensLogger,
              isAndroidRawLogsEnabled: isAndroidRawLogsEnabled,
            ),
          ],
        ),
        floatingActionButton:
            isLoggerTab
                ? _LoggerFloatingActionButtons(scrollLogsList: _scrollLogsList)
                : null,
      ),
    );
  }

  /// Get tab name based on [item] type.
  String _getTabName({required NetLensCallsListTabItem item}) {
    switch (item) {
      case NetLensCallsListTabItem.inspector:
        return context.i18n(NetLensTranslationKey.callsListInspector);
      case NetLensCallsListTabItem.logger:
        return context.i18n(NetLensTranslationKey.callsListLogger);
    }
  }

  /// Called when back button has been pressed. It navigates back to original
  /// application.
  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  /// Called when clear logs has been pressed. It displays dialog and awaits for
  /// user confirmation.
  void _onClearLogsPressed() => NetLensGeneralDialog.show(
    context: context,
    title: context.i18n(NetLensTranslationKey.callsListDeleteLogsDialogTitle),
    description: context.i18n(
      NetLensTranslationKey.callsListDeleteLogsDialogDescription,
    ),
    firstButtonTitle: context.i18n(NetLensTranslationKey.callsListNo),
    secondButtonTitle: context.i18n(NetLensTranslationKey.callsListYes),
    secondButtonAction: _onLogsClearPressed,
  );

  /// Called when logs type mode pressed.
  void _onLogsChangePressed() => setState(() {
    isAndroidRawLogsEnabled = !isAndroidRawLogsEnabled;
  });

  /// Called when logs clear button has been pressed.
  void _onLogsClearPressed() => setState(() {
    if (isAndroidRawLogsEnabled) {
      widget.core.configuration.netLensLogger.clearAndroidRawLogs();
    } else {
      widget.core.configuration.netLensLogger.clearLogs();
    }
  });

  /// Called when search button. It displays search text field.
  void _onSearchPressed() => setState(() {
    _searchEnabled = !_searchEnabled;
    if (!_searchEnabled) {
      _queryTextEditingController.text = '';
    }
  });

  /// Called on tab has been changed.
  void _onTabChanged(int index) => setState(() {
    _selectedIndex = index;
    if (_selectedIndex == 1) {
      _searchEnabled = false;
      _queryTextEditingController.text = '';
    }
  });

  /// Called when menu item from overflow menu has been pressed.
  void _onMenuItemSelected(NetLensCallDetailsMenuItemType menuItem) {
    switch (menuItem) {
      case NetLensCallDetailsMenuItemType.sort:
        _onSortPressed();
      case NetLensCallDetailsMenuItemType.delete:
        _onRemovePressed();
      case NetLensCallDetailsMenuItemType.stats:
        _onStatsPressed();
      case NetLensCallDetailsMenuItemType.timeline:
        NetLensNavigation.navigateToTimeline(core: netLensCore);
      case NetLensCallDetailsMenuItemType.save:
        _saveToFile();
      case NetLensCallDetailsMenuItemType.exportHar:
        _exportHar();
    }
  }

  /// Called when item from the list has been pressed. It opens details page.
  void _onListItemPressed(NetLensHttpCall call) =>
      NetLensNavigation.navigateToCallDetails(call: call, core: netLensCore);

  /// Called when remove all calls button has been pressed.
  void _onRemovePressed() => NetLensGeneralDialog.show(
    context: context,
    title: context.i18n(NetLensTranslationKey.callsListDeleteCallsDialogTitle),
    description: context.i18n(
      NetLensTranslationKey.callsListDeleteCallsDialogDescription,
    ),
    firstButtonTitle: context.i18n(NetLensTranslationKey.callsListNo),
    firstButtonAction: () => <String, dynamic>{},
    secondButtonTitle: context.i18n(NetLensTranslationKey.callsListYes),
    secondButtonAction: _removeCalls,
  );

  /// Removes all calls from NetLens.
  void _removeCalls() => netLensCore.removeCalls();

  /// Called when stats button has been pressed. Navigates to stats page.
  void _onStatsPressed() {
    NetLensNavigation.navigateToStats(core: netLensCore);
  }

  /// Called when save to file has been pressed. It saves data to file.
  void _saveToFile() async {
    if (!mounted) return;
    final result = await netLensCore.saveCallsToFile(context);

    if (result.success && result.path != null) {
      NetLensGeneralDialog.show(
        context: context,
        title: context.i18n(NetLensTranslationKey.saveSuccessTitle),
        description: context
            .i18n(NetLensTranslationKey.saveSuccessDescription)
            .replaceAll("[path]", result.path!),
        secondButtonTitle:
            OperatingSystem.isAndroid
                ? context.i18n(NetLensTranslationKey.saveSuccessView)
                : null,
        secondButtonAction:
            () =>
                OperatingSystem.isAndroid ? OpenFilex.open(result.path!) : null,
      );
    } else {
      final [String title, String description] = switch (result.error) {
        NetLensExportResultError.logGenerate => [
          context.i18n(NetLensTranslationKey.saveDialogPermissionErrorTitle),
          context.i18n(
            NetLensTranslationKey.saveDialogPermissionErrorDescription,
          ),
        ],
        NetLensExportResultError.empty => [
          context.i18n(NetLensTranslationKey.saveDialogEmptyErrorTitle),
          context.i18n(NetLensTranslationKey.saveDialogEmptyErrorDescription),
        ],
        NetLensExportResultError.permission => [
          context.i18n(NetLensTranslationKey.saveDialogPermissionErrorTitle),
          context.i18n(
            NetLensTranslationKey.saveDialogPermissionErrorDescription,
          ),
        ],
        NetLensExportResultError.file => [
          context.i18n(NetLensTranslationKey.saveDialogFileSaveErrorTitle),
          context.i18n(
            NetLensTranslationKey.saveDialogFileSaveErrorDescription,
          ),
        ],
        _ => ["", ""],
      };

      NetLensGeneralDialog.show(
        context: context,
        title: title,
        description: description,
      );
    }
  }

  /// Saves calls to a HAR file and opens the share sheet with it.
  Future<void> _exportHar() async {
    final NetLensExportResult result = await netLensCore.saveCallsToHarFile();
    if (!mounted || result.success) {
      return;
    }
    final bool isEmpty = result.error == NetLensExportResultError.empty;
    NetLensGeneralDialog.show(
      context: context,
      title: context.i18n(
        isEmpty
            ? NetLensTranslationKey.saveDialogEmptyErrorTitle
            : NetLensTranslationKey.saveDialogFileSaveErrorTitle,
      ),
      description: context.i18n(
        isEmpty
            ? NetLensTranslationKey.saveDialogEmptyErrorDescription
            : NetLensTranslationKey.saveDialogFileSaveErrorDescription,
      ),
    );
  }

  /// Called when clear search button has been pressed. Clears the query.
  void _onClearSearchPressed() => setState(() {
    _queryTextEditingController.clear();
  });

  /// Filters calls based on query.
  void _updateSearchQuery(String query) => setState(() {});

  /// Called when sort button has been pressed. It opens dialog where filters
  /// can be picked.
  Future<void> _onSortPressed() async {
    NetLensSortDialogResult? result = await showDialog<NetLensSortDialogResult>(
      context: context,
      builder:
          (_) => NetLensSortDialog(
            sortOption: _sortOption,
            sortAscending: _sortAscending,
          ),
    );
    if (result != null) {
      setState(() {
        _sortOption = result.sortOption;
        _sortAscending = result.sortAscending;
      });
    }
  }

  /// Scrolls logs list based on [top] parameter.
  void _scrollLogsList(bool top) => top ? _scrollToTop() : _scrollToBottom();

  /// Scrolls logs list to the top.
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  /// Scrolls logs list to the bottom.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }
}

/// Text field displayed in app bar. Used to search call logs.
class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.textEditingController,
    required this.onChanged,
    required this.onClearPressed,
  });

  final TextEditingController textEditingController;
  final void Function(String) onChanged;
  final void Function() onClearPressed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: context.i18n(NetLensTranslationKey.callsListSearchHint),
        hintStyle: const TextStyle(fontSize: 16, color: NetLensTheme.grey),
        border: InputBorder.none,
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: textEditingController,
          builder:
              (context, value, _) =>
                  value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                        icon: const Icon(Icons.backspace_outlined, size: 20),
                        tooltip: context.i18n(
                          NetLensTranslationKey.callsListClearSearch,
                        ),
                        onPressed: onClearPressed,
                      ),
        ),
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: onChanged,
    );
  }
}

/// Menu button displayed in app bar. It displays overflow menu with additional
/// actions.
class _ContextMenuButton extends StatelessWidget {
  const _ContextMenuButton({required this.onMenuItemSelected});

  final void Function(NetLensCallDetailsMenuItemType) onMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NetLensCallDetailsMenuItemType>(
      icon: const Icon(Icons.more_vert),
      onSelected: onMenuItemSelected,
      itemBuilder:
          (BuildContext context) => [
            for (final NetLensCallDetailsMenuItemType item
                in NetLensCallDetailsMenuItemType.values)
              PopupMenuItem<NetLensCallDetailsMenuItemType>(
                value: item,
                child: Row(
                  children: [
                    Icon(
                      _getIcon(itemType: item),
                      color: NetLensTheme.lightRed,
                    ),
                    const SizedBox(width: 12),
                    Text(_getTitle(context: context, itemType: item)),
                  ],
                ),
              ),
          ],
    );
  }

  /// Get title of the menu item based on [itemType].
  String _getTitle({
    required BuildContext context,
    required NetLensCallDetailsMenuItemType itemType,
  }) {
    switch (itemType) {
      case NetLensCallDetailsMenuItemType.sort:
        return context.i18n(NetLensTranslationKey.callsListSort);
      case NetLensCallDetailsMenuItemType.delete:
        return context.i18n(NetLensTranslationKey.callsListDelete);
      case NetLensCallDetailsMenuItemType.stats:
        return context.i18n(NetLensTranslationKey.callsListStats);
      case NetLensCallDetailsMenuItemType.timeline:
        return context.i18n(NetLensTranslationKey.callsListTimeline);
      case NetLensCallDetailsMenuItemType.save:
        return context.i18n(NetLensTranslationKey.callsListSave);
      case NetLensCallDetailsMenuItemType.exportHar:
        return context.i18n(NetLensTranslationKey.callsListExportHar);
    }
  }

  /// Get icon of the menu item based [itemType].
  IconData _getIcon({required NetLensCallDetailsMenuItemType itemType}) {
    switch (itemType) {
      case NetLensCallDetailsMenuItemType.sort:
        return Icons.sort;
      case NetLensCallDetailsMenuItemType.delete:
        return Icons.delete_outline;
      case NetLensCallDetailsMenuItemType.stats:
        return Icons.insert_chart;
      case NetLensCallDetailsMenuItemType.timeline:
        return Icons.view_timeline_outlined;
      case NetLensCallDetailsMenuItemType.save:
        return Icons.save_outlined;
      case NetLensCallDetailsMenuItemType.exportHar:
        return Icons.ios_share;
    }
  }
}

/// FAB buttons used to scroll logs. Displayed only in logs tab.
class _LoggerFloatingActionButtons extends StatelessWidget {
  const _LoggerFloatingActionButtons({required this.scrollLogsList});

  final void Function(bool) scrollLogsList;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'h1',
          mini: true,
          tooltip: context.i18n(NetLensTranslationKey.callsListScrollTop),
          backgroundColor: NetLensTheme.lightRed,
          onPressed: () => scrollLogsList(true),
          child: const Icon(Icons.arrow_upward, color: NetLensTheme.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'h2',
          mini: true,
          tooltip: context.i18n(NetLensTranslationKey.callsListScrollBottom),
          backgroundColor: NetLensTheme.lightRed,
          onPressed: () => scrollLogsList(false),
          child: const Icon(Icons.arrow_downward, color: NetLensTheme.white),
        ),
      ],
    );
  }
}
