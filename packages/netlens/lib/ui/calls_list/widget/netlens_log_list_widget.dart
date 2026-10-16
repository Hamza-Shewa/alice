import 'dart:convert';

import 'package:netlens/helper/netlens_log_classifier.dart';
import 'package:netlens/model/netlens_log.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_logs_widget.dart';
import 'package:netlens/ui/calls_list/widget/netlens_error_logs_widget.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_detail_widgets.dart';
import 'package:netlens/ui/common/netlens_issue_widgets.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Filter applied to the list of logs.
enum NetLensLogFilter {
  all,
  requests,
  responses,
  errors,
  warnings;

  /// Whether a log described by [info] passes the filter.
  bool matches(NetLensLogInfo info) => switch (this) {
    NetLensLogFilter.all => true,
    NetLensLogFilter.requests => info.kind == NetLensLogKind.request,
    NetLensLogFilter.responses =>
      info.kind == NetLensLogKind.response || info.status != null,
    NetLensLogFilter.errors => info.isFailure,
    NetLensLogFilter.warnings => info.kind == NetLensLogKind.warning,
  };

  NetLensTranslationKey get label => switch (this) {
    NetLensLogFilter.all => NetLensTranslationKey.logsFilterAll,
    NetLensLogFilter.requests => NetLensTranslationKey.logsFilterRequests,
    NetLensLogFilter.responses => NetLensTranslationKey.logsFilterResponses,
    NetLensLogFilter.errors => NetLensTranslationKey.logsFilterErrors,
    NetLensLogFilter.warnings => NetLensTranslationKey.logsFilterWarnings,
  };

  IconData get icon => switch (this) {
    NetLensLogFilter.all => Icons.notes,
    NetLensLogFilter.requests => Icons.arrow_upward,
    NetLensLogFilter.responses => Icons.arrow_downward,
    NetLensLogFilter.errors => Icons.error_outline,
    NetLensLogFilter.warnings => Icons.warning_amber_outlined,
  };
}

/// Widget which renders log list for calls list page. API calls and errors
/// are detected in the logs, colored by kind and can be filtered.
class NetLensLogListWidget extends StatefulWidget {
  const NetLensLogListWidget({
    required this.logsStream,
    required this.scrollController,
    this.initialLogs,
    super.key,
  });

  final Stream<List<NetLensLog>>? logsStream;

  /// Logs displayed until the stream emits, so the list doesn't flash a
  /// loading indicator when it is opened.
  final List<NetLensLog>? initialLogs;
  final ScrollController? scrollController;

  @override
  State<NetLensLogListWidget> createState() => _NetLensLogListWidgetState();
}

/// State for logs list widget.
class _NetLensLogListWidgetState extends State<NetLensLogListWidget> {
  final DiagnosticLevel _minLevel = DiagnosticLevel.debug;
  NetLensLogFilter _filter = NetLensLogFilter.all;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NetLensLog>>(
      stream: widget.logsStream,
      initialData: widget.initialLogs,
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            (snapshot.connectionState == ConnectionState.none ||
                snapshot.connectionState == ConnectionState.waiting)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const NetLensErrorLogsWidget();
        }

        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const NetLensEmptyLogsWidget();
        }

        final List<(NetLensLog, NetLensLogInfo)> entries = [
          for (final NetLensLog log in logs)
            if (log.level.index >= _minLevel.index)
              (log, NetLensLogClassifier.classify(log)),
        ];
        final List<(NetLensLog, NetLensLogInfo)> filtered = [
          for (final entry in entries)
            if (_filter.matches(entry.$2)) entry,
        ];

        return Column(
          children: [
            _FilterBar(
              selected: _filter,
              counts: {
                for (final NetLensLogFilter filter in NetLensLogFilter.values)
                  filter: entries.where((e) => filter.matches(e.$2)).length,
              },
              onSelected: (NetLensLogFilter filter) {
                setState(() => _filter = filter);
              },
            ),
            Expanded(
              child:
                  filtered.isEmpty
                      ? Center(
                        child: Text(
                          context.i18n(NetLensTranslationKey.logsFilterEmpty),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                      : SelectionArea(
                        child: ScrollConfiguration(
                          behavior: NetLensScrollBehavior(),
                          child: ListView.builder(
                            controller: widget.scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder:
                                (context, i) => _NetLensLogEntryWidget(
                                  filtered[i].$1,
                                  filtered[i].$2,
                                ),
                          ),
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }
}

/// Horizontal list of chips which filter logs by kind.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final NetLensLogFilter selected;
  final Map<NetLensLogFilter, int> counts;
  final void Function(NetLensLogFilter) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final NetLensLogFilter filter in NetLensLogFilter.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: FilterChip(
                showCheckmark: false,
                selected: filter == selected,
                avatar: Icon(
                  filter.icon,
                  size: 16,
                  color: _filterColor(context, filter),
                ),
                label: Text(
                  '${context.i18n(filter.label)} ${counts[filter] ?? 0}',
                ),
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }

  Color _filterColor(BuildContext context, NetLensLogFilter filter) =>
      switch (filter) {
        NetLensLogFilter.all => Theme.of(context).colorScheme.onSurfaceVariant,
        NetLensLogFilter.requests => NetLensTheme.getLogKindColor(
          context,
          const NetLensLogInfo(kind: NetLensLogKind.request),
        ),
        NetLensLogFilter.responses => NetLensTheme.getLogKindColor(
          context,
          const NetLensLogInfo(kind: NetLensLogKind.response, status: 200),
        ),
        NetLensLogFilter.errors => NetLensTheme.getLogKindColor(
          context,
          const NetLensLogInfo(kind: NetLensLogKind.error),
        ),
        NetLensLogFilter.warnings => NetLensTheme.getLogKindColor(
          context,
          const NetLensLogInfo(kind: NetLensLogKind.warning),
        ),
      };
}

/// Widget which renders one log entry in logs list.
class _NetLensLogEntryWidget extends StatelessWidget {
  _NetLensLogEntryWidget(this.log, this.info) : super(key: ValueKey(log));

  final NetLensLog log;
  final NetLensLogInfo info;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = NetLensTheme.getLogTextColor(context, log.level);
    final Color kindColor = NetLensTheme.getLogKindColor(context, info);
    final bool isHighlighted = info.kind != NetLensLogKind.info;

    final String rawTimestamp = log.timestamp.toString();
    final String time = rawTimestamp.substring(rawTimestamp.indexOf(' ') + 1);
    final String? error = _stringify(log.error);
    final String? stackTrace = _stringify(log.stackTrace);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              isHighlighted
                  ? kindColor.withValues(alpha: 0.07)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: BorderDirectional(
            start: BorderSide(
              color: isHighlighted ? kindColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _KindChip(info: info, color: kindColor),
                        if (info.origin != null)
                          NetLensIssueChip(origin: info.origin!),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    visualDensity: VisualDensity.compact,
                    tooltip: context.i18n(
                      NetLensTranslationKey.callOverviewCopy,
                    ),
                    onPressed:
                        () => _copyToClipboard(context, error, stackTrace),
                  ),
                ],
              ),
              if (info.url != null) ...[
                const SizedBox(height: 4),
                NetLensLtrText(
                  info.url!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kindColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: _CollapsibleMessage(text: log.message, color: color),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: _LabeledBlock(
                    label: netLensStripColon(
                      context.i18n(NetLensTranslationKey.logsItemError),
                    ),
                    text: error,
                    isError: true,
                  ),
                ),
              ],
              if (stackTrace != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: _LabeledBlock(
                    label: netLensStripColon(
                      context.i18n(NetLensTranslationKey.logsItemStackTrace),
                    ),
                    text: stackTrace,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Copies the whole log entry to clipboard.
  Future<void> _copyToClipboard(
    BuildContext context,
    String? error,
    String? stackTrace,
  ) async {
    final StringBuffer text =
        StringBuffer()..writeAll([
          '${log.timestamp}: ${log.message}\n',
          if (error != null)
            '${context.i18n(NetLensTranslationKey.logsItemError)} $error\n',
          if (stackTrace != null)
            '${context.i18n(NetLensTranslationKey.logsItemStackTrace)}: $stackTrace\n',
        ]);

    await Clipboard.setData(ClipboardData(text: text.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.i18n(NetLensTranslationKey.logsCopied))),
      );
    }
  }

  /// Formats text with json decode/encode.
  String? _stringify(dynamic object) {
    if (object == null) return null;
    if (object is String) return object.trim();
    if (object is DiagnosticsNode) return object.toStringDeep();

    try {
      // ignore: avoid_dynamic_calls
      object.toJson();
      // It supports `toJson()`.

      dynamic toEncodable(dynamic object) {
        try {
          // ignore: avoid_dynamic_calls
          return object.toJson();
        } catch (_) {
          try {
            return '$object';
          } catch (_) {
            return describeIdentity(object);
          }
        }
      }

      return JsonEncoder.withIndent('  ', toEncodable).convert(object);
    } catch (_) {}

    try {
      return '$object'.trim();
    } catch (_) {
      return describeIdentity(object);
    }
  }
}

/// Rounded label with the kind of the log, for example `RESPONSE 404`.
class _KindChip extends StatelessWidget {
  const _KindChip({required this.info, required this.color});

  final NetLensLogInfo info;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String label = context.i18n(switch (info.kind) {
      NetLensLogKind.request => NetLensTranslationKey.logKindRequest,
      NetLensLogKind.response => NetLensTranslationKey.logKindResponse,
      NetLensLogKind.error => NetLensTranslationKey.logKindError,
      NetLensLogKind.warning => NetLensTranslationKey.logKindWarning,
      NetLensLogKind.info => NetLensTranslationKey.logKindInfo,
    });
    final String detail = [
      if (info.method != null) info.method!,
      if (info.status != null) '${info.status}',
    ].join(' ');
    final IconData icon = switch (info.kind) {
      NetLensLogKind.request => Icons.arrow_upward,
      NetLensLogKind.response => Icons.arrow_downward,
      NetLensLogKind.error => Icons.error_outline,
      NetLensLogKind.warning => Icons.warning_amber_outlined,
      NetLensLogKind.info => Icons.info_outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            detail.isEmpty
                ? label.toUpperCase()
                : '${label.toUpperCase()} $detail',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Log message which collapses when it is long.
class _CollapsibleMessage extends StatefulWidget {
  const _CollapsibleMessage({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  State<_CollapsibleMessage> createState() => _CollapsibleMessageState();
}

class _CollapsibleMessageState extends State<_CollapsibleMessage> {
  static const int _collapsedLines = 6;
  static const int _collapsedChars = 500;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = widget.text.split('\n');
    final bool isLong =
        lines.length > _collapsedLines || widget.text.length > _collapsedChars;
    String shown = widget.text;
    if (isLong && !_expanded) {
      shown = lines.take(_collapsedLines).join('\n');
      if (shown.length > _collapsedChars) {
        shown = shown.substring(0, _collapsedChars);
      }
      shown += '…';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shown,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Courier', 'Menlo'],
            fontSize: 12.5,
            height: 1.45,
            color: widget.color,
          ),
        ),
        if (isLong)
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
            ),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              context.i18n(
                _expanded
                    ? NetLensTranslationKey.callOverviewShowLess
                    : NetLensTranslationKey.callOverviewShowMore,
              ),
            ),
          ),
      ],
    );
  }
}

/// Small label above a code block, used for errors and stack traces.
class _LabeledBlock extends StatelessWidget {
  const _LabeledBlock({
    required this.label,
    required this.text,
    this.isError = false,
  });

  final String label;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        NetLensCodeBlock(text: text, isError: isError),
      ],
    );
  }
}
