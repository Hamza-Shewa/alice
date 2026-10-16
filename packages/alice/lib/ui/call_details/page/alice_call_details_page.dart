// ignore_for_file: use_build_context_synchronously

import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_call_redactor.dart';
import 'package:alice/helper/alice_export_helper.dart';
import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/call_details/model/alice_call_details_tab.dart';
import 'package:alice/ui/call_details/widget/alice_call_error_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_overview_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_request_screen.dart';
import 'package:alice/ui/call_details/widget/alice_call_response_screen.dart';
import 'package:alice/ui/common/alice_app_bar.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/common/alice_settings.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Call details page which displays 4 tabs: overview, request, response, error.
class AliceCallDetailsPage extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsPage({
    required this.call,
    required this.core,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AliceCallDetailsPageState();
}

/// State of call details page.
class _AliceCallDetailsPageState extends State<AliceCallDetailsPage>
    with SingleTickerProviderStateMixin, AliceSettingsListenerMixin {
  late final TabController _tabController = TabController(
    length: AliceCallDetailsTabItem.values.length,
    vsync: this,
  );

  AliceHttpCall get call => widget.call;

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
    return AlicePage(
      core: widget.core,
      child: StreamBuilder<List<AliceHttpCall>>(
        stream: widget.core.callsStream,
        initialData: [widget.call],
        builder: (context, AsyncSnapshot<List<AliceHttpCall>> callsSnapshot) {
          if (callsSnapshot.hasData && !callsSnapshot.hasError) {
            final AliceHttpCall? currentCall = callsSnapshot.data
                ?.firstWhereOrNull(
                  (AliceHttpCall snapshotCall) =>
                      snapshotCall.id == widget.call.id,
                );
            if (currentCall != null) {
              final Object signature = (
                currentCall.loading,
                identityHashCode(currentCall.response),
                identityHashCode(currentCall.error),
                currentCall.duration,
                currentCall.response?.status,
                AliceLanguage.current.value,
                AliceTheme.themeMode.value,
                AliceWatcher.instance.version,
                _revealSensitive,
              );
              if (_cachedPage != null && _cachedSignature == signature) {
                return _cachedPage!;
              }
              _cachedSignature = signature;
              final AliceCallRedactor redactor = widget.core.redactor;
              final bool canRedact = !redactor.redaction.isEmpty;
              final AliceHttpCall shownCall =
                  _revealSensitive ? currentCall : redactor.redact(currentCall);
              return _cachedPage = Scaffold(
                appBar: AliceAppBar(
                  actions: [
                    AliceSettingsButton(core: widget.core),
                    if (canRedact)
                      IconButton(
                        icon: Icon(
                          _revealSensitive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        tooltip: context.i18n(
                          _revealSensitive
                              ? AliceTranslationKey.callDetailsHideSensitive
                              : AliceTranslationKey.callDetailsRevealSensitive,
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
                        tooltip: context.i18n(AliceTranslationKey.replayAction),
                        onPressed:
                            () => AliceNavigation.navigateToReplay(
                              call: currentCall,
                              core: widget.core,
                            ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy_all),
                      tooltip: context.i18n(
                        AliceTranslationKey.callOverviewCopyAll,
                      ),
                      onPressed: () => _copyCall(currentCall),
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: AliceTheme.lightRed,
                    tabs:
                        AliceCallDetailsTabItem.values.map((item) {
                          return Tab(
                            icon: _getTabIcon(item: item),
                            text: _getTabName(item: item),
                          );
                        }).toList(),
                  ),
                  title: Text(
                    '${context.i18n(AliceTranslationKey.alice)} -'
                    ' ${context.i18n(AliceTranslationKey.callDetails)}',
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    AliceCallOverviewScreen(call: shownCall),
                    AliceCallRequestScreen(call: shownCall),
                    AliceCallResponseScreen(call: shownCall),
                    AliceCallErrorScreen(call: shownCall),
                  ],
                ),
                floatingActionButton:
                    widget.core.configuration.showShareButton
                        ? FloatingActionButton(
                          backgroundColor: AliceTheme.lightRed,
                          key: const Key('share_key'),
                          onPressed: () => _shareCall(currentCall),
                          child: const Icon(
                            Icons.share,
                            color: AliceTheme.white,
                          ),
                        )
                        : null,
              );
            }
          }

          return Center(
            child: Text(context.i18n(AliceTranslationKey.callDetailsEmpty)),
          );
        },
      ),
    );
  }

  /// Called when share button has been pressed. It encodes the [call]
  /// and tries to invoke system action to share it.
  Future<void> _shareCall(AliceHttpCall call) async {
    await AliceExportHelper.shareCall(
      context: context,
      call: widget.core.redactor.redact(call),
    );
  }

  /// Copies everything related to [call] (general data, request and
  /// response headers and bodies, error and curl) to clipboard.
  Future<void> _copyCall(AliceHttpCall call) async {
    final String log = AliceExportHelper.buildCallLog(
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
            context.i18n(AliceTranslationKey.callOverviewCopiedAll),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Get tab name based on [item] type.
  String _getTabName({required AliceCallDetailsTabItem item}) {
    switch (item) {
      case AliceCallDetailsTabItem.overview:
        return context.i18n(AliceTranslationKey.callDetailsOverview);
      case AliceCallDetailsTabItem.request:
        return context.i18n(AliceTranslationKey.callDetailsRequest);
      case AliceCallDetailsTabItem.response:
        return context.i18n(AliceTranslationKey.callDetailsResponse);
      case AliceCallDetailsTabItem.error:
        return context.i18n(AliceTranslationKey.callDetailsError);
    }
  }

  /// Get tab icon based on [item] type.
  Icon _getTabIcon({required AliceCallDetailsTabItem item}) {
    switch (item) {
      case AliceCallDetailsTabItem.overview:
        return const Icon(Icons.info_outline);
      case AliceCallDetailsTabItem.request:
        return const Icon(Icons.arrow_upward);
      case AliceCallDetailsTabItem.response:
        return const Icon(Icons.arrow_downward);
      case AliceCallDetailsTabItem.error:
        return const Icon(Icons.warning);
    }
  }
}
