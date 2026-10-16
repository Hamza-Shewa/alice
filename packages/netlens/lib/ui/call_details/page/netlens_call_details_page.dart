// ignore_for_file: use_build_context_synchronously

import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_call_redactor.dart';
import 'package:netlens/helper/netlens_export_helper.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/call_details/model/netlens_call_details_tab.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_error_screen.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_overview_screen.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_request_screen.dart';
import 'package:netlens/ui/call_details/widget/netlens_call_response_screen.dart';
import 'package:netlens/ui/common/netlens_app_bar.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';
import 'package:netlens/ui/common/netlens_page.dart';
import 'package:netlens/ui/common/netlens_settings.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Call details page which displays 4 tabs: overview, request, response, error.
class NetLensCallDetailsPage extends StatefulWidget {
  final NetLensHttpCall call;
  final NetLensCore core;

  const NetLensCallDetailsPage({
    required this.call,
    required this.core,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _NetLensCallDetailsPageState();
}

/// State of call details page.
class _NetLensCallDetailsPageState extends State<NetLensCallDetailsPage>
    with SingleTickerProviderStateMixin, NetLensSettingsListenerMixin {
  late final TabController _tabController = TabController(
    length: NetLensCallDetailsTabItem.values.length,
    vsync: this,
  );

  NetLensHttpCall get call => widget.call;

  /// Last built page and what it was built from. The calls stream emits for
  /// every call of the app, which would rebuild all tabs and make scrolling
  /// stutter while requests are running. The page is rebuilt only when this
  /// call or a setting changes.
  Widget? _cachedPage;
  Object? _cachedSignature;

  /// When true, sensitive values are shown instead of the mask.
  bool _revealSensitive = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NetLensPage(
      core: widget.core,
      child: StreamBuilder<List<NetLensHttpCall>>(
        stream: widget.core.callsStream,
        initialData: [widget.call],
        builder: (context, AsyncSnapshot<List<NetLensHttpCall>> callsSnapshot) {
          if (callsSnapshot.hasData && !callsSnapshot.hasError) {
            final NetLensHttpCall? currentCall = callsSnapshot.data
                ?.firstWhereOrNull(
                  (NetLensHttpCall snapshotCall) =>
                      snapshotCall.id == widget.call.id,
                );
            if (currentCall != null) {
              final Object signature = (
                currentCall.loading,
                identityHashCode(currentCall.response),
                identityHashCode(currentCall.error),
                currentCall.duration,
                currentCall.response?.status,
                NetLensLanguage.current.value,
                NetLensTheme.themeMode.value,
                NetLensWatcher.instance.version,
                _revealSensitive,
              );
              if (_cachedPage != null && _cachedSignature == signature) {
                return _cachedPage!;
              }
              _cachedSignature = signature;
              final NetLensCallRedactor redactor = widget.core.redactor;
              final bool canRedact = !redactor.redaction.isEmpty;
              final NetLensHttpCall shownCall =
                  _revealSensitive ? currentCall : redactor.redact(currentCall);
              return _cachedPage = Scaffold(
                appBar: NetLensAppBar(
                  actions: [
                    NetLensSettingsButton(core: widget.core),
                    if (canRedact)
                      IconButton(
                        icon: Icon(
                          _revealSensitive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        tooltip: context.i18n(
                          _revealSensitive
                              ? NetLensTranslationKey.callDetailsHideSensitive
                              : NetLensTranslationKey
                                  .callDetailsRevealSensitive,
                        ),
                        onPressed:
                            () => setState(
                              () => _revealSensitive = !_revealSensitive,
                            ),
                      ),
                    if (!currentCall.loading &&
                        widget.core.canReplay(currentCall))
                      IconButton(
                        icon: const Icon(Icons.replay),
                        tooltip: context.i18n(
                          NetLensTranslationKey.replayAction,
                        ),
                        onPressed:
                            () => NetLensNavigation.navigateToReplay(
                              call: currentCall,
                              core: widget.core,
                            ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy_all),
                      tooltip: context.i18n(
                        NetLensTranslationKey.callOverviewCopyAll,
                      ),
                      onPressed: () => _copyCall(currentCall),
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: NetLensTheme.lightRed,
                    tabs:
                        NetLensCallDetailsTabItem.values.map((item) {
                          return Tab(
                            icon: _getTabIcon(item: item),
                            text: _getTabName(item: item),
                          );
                        }).toList(),
                  ),
                  title: Text(
                    '${context.i18n(NetLensTranslationKey.netLens)} -'
                    ' ${context.i18n(NetLensTranslationKey.callDetails)}',
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    NetLensCallOverviewScreen(call: shownCall),
                    NetLensCallRequestScreen(call: shownCall),
                    NetLensCallResponseScreen(call: shownCall),
                    NetLensCallErrorScreen(call: shownCall),
                  ],
                ),
                floatingActionButton:
                    widget.core.configuration.showShareButton
                        ? FloatingActionButton(
                          backgroundColor: NetLensTheme.lightRed,
                          key: const Key('share_key'),
                          onPressed: () => _shareCall(currentCall),
                          child: const Icon(
                            Icons.share,
                            color: NetLensTheme.white,
                          ),
                        )
                        : null,
              );
            }
          }

          return Center(
            child: Text(context.i18n(NetLensTranslationKey.callDetailsEmpty)),
          );
        },
      ),
    );
  }

  /// Called when share button has been pressed. It encodes the [call]
  /// and tries to invoke system action to share it.
  Future<void> _shareCall(NetLensHttpCall call) async {
    await NetLensExportHelper.shareCall(
      context: context,
      call: widget.core.redactor.redact(call),
    );
  }

  /// Copies everything related to [call] (general data, request and
  /// response headers and bodies, error and curl) to clipboard.
  Future<void> _copyCall(NetLensHttpCall call) async {
    final String log = NetLensExportHelper.buildCallLog(
      context: context,
      call: widget.core.redactor.redact(call),
    );
    await Clipboard.setData(ClipboardData(text: log));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            context.i18n(NetLensTranslationKey.callOverviewCopiedAll),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Get tab name based on [item] type.
  String _getTabName({required NetLensCallDetailsTabItem item}) {
    switch (item) {
      case NetLensCallDetailsTabItem.overview:
        return context.i18n(NetLensTranslationKey.callDetailsOverview);
      case NetLensCallDetailsTabItem.request:
        return context.i18n(NetLensTranslationKey.callDetailsRequest);
      case NetLensCallDetailsTabItem.response:
        return context.i18n(NetLensTranslationKey.callDetailsResponse);
      case NetLensCallDetailsTabItem.error:
        return context.i18n(NetLensTranslationKey.callDetailsError);
    }
  }

  /// Get tab icon based on [item] type.
  Icon _getTabIcon({required NetLensCallDetailsTabItem item}) {
    switch (item) {
      case NetLensCallDetailsTabItem.overview:
        return const Icon(Icons.info_outline);
      case NetLensCallDetailsTabItem.request:
        return const Icon(Icons.arrow_upward);
      case NetLensCallDetailsTabItem.response:
        return const Icon(Icons.arrow_downward);
      case NetLensCallDetailsTabItem.error:
        return const Icon(Icons.warning);
    }
  }
}
