import 'package:netlens/helper/netlens_conversion_helper.dart';
import 'package:netlens/helper/netlens_graphql.dart';
import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/helper/netlens_url_validator.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/ui/common/netlens_call_badges.dart';
import 'package:netlens/ui/common/netlens_issue_widgets.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:netlens/ui/common/netlens_watcher_widgets.dart';
import 'package:netlens/ui/common/netlens_url_issue_banner.dart';
import 'package:flutter/material.dart';

const int _endpointMaxLines = 2;
const double _statusBarWidth = 4;
const double _urlIssueBarWidth = 6;

/// Widget which renders one row in calls list view. It displays general
/// information about call.
class NetLensCallListItemWidget extends StatelessWidget {
  const NetLensCallListItemWidget(this.call, this.itemClickAction, {super.key});

  final NetLensHttpCall call;
  final void Function(NetLensHttpCall) itemClickAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color statusColor =
        call.loading
            ? NetLensTheme.grey
            : NetLensTheme.getStatusColor(context, call.response?.status);
    final List<NetLensUrlIssue> urlIssues = NetLensUrlValidator.validateCall(
      call,
    );
    final bool hasUrlIssues = urlIssues.isNotEmpty;
    final Color urlIssueColor = getUrlIssueColor(context);
    final NetLensIssue? issue = NetLensIssueAnalyzer.analyze(call);
    final NetLensWatchResult? watch = NetLensWatcher.instance.evaluate(call);
    final NetLensGraphQLOperation? graphQL = NetLensGraphQL.detect(call);

    return InkWell(
      onTap: () => itemClickAction.call(call),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hasUrlIssues ? urlIssueColor.withValues(alpha: 0.05) : null,
          border: BorderDirectional(
            start:
                hasUrlIssues
                    ? BorderSide(color: urlIssueColor, width: _urlIssueBarWidth)
                    : BorderSide(color: statusColor, width: _statusBarWidth),
            bottom: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetLensMethodBadge(method: call.method),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Endpoint(
                      call: call,
                      title: graphQL?.title,
                      hasUrlIssues: hasUrlIssues,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    // The chip ellipsizes, so a long label can't squeeze the
                    // endpoint away on narrow screens.
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        NetLensStatusPill(call: call),
                        if (watch != null) ...[
                          const SizedBox(height: 4),
                          NetLensWatchChip(result: watch),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _ServerAddress(
                call: call,
                path: graphQL != null ? call.endpoint : null,
                hasUrlIssues: hasUrlIssues,
              ),
              if (graphQL != null) ...[
                const SizedBox(height: 6),
                NetLensGraphQLBadge(operation: graphQL),
              ],
              if (hasUrlIssues) ...[
                const SizedBox(height: 10),
                NetLensUrlIssueBanner(issues: urlIssues, compact: true),
              ],
              const SizedBox(height: 8),
              _ConnectionStats(call: call),
              if (issue != null) ...[
                const SizedBox(height: 8),
                NetLensIssueChip(origin: issue.origin),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget which renders endpoint of the call, or [title] when it is set.
class _Endpoint extends StatelessWidget {
  const _Endpoint({required this.call, required this.hasUrlIssues, this.title});

  final NetLensHttpCall call;
  final bool hasUrlIssues;

  /// Text shown instead of the endpoint, for example a GraphQL operation.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      title ?? call.endpoint,
      maxLines: _endpointMaxLines,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall
          ?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
            color:
                call.loading
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
          )
          .merge(hasUrlIssues ? _urlIssueTextStyle(context) : null),
    );
  }
}

/// Widget which renders server address line, followed by [path] when set.
class _ServerAddress extends StatelessWidget {
  const _ServerAddress({
    required this.call,
    required this.hasUrlIssues,
    this.path,
  });

  final NetLensHttpCall call;
  final bool hasUrlIssues;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          call.secure ? Icons.lock_outline : Icons.lock_open,
          color: NetLensTheme.getStatusColor(context, call.secure ? 200 : 400),
          size: 14,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            path != null ? '${call.server}$path' : call.server,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                .merge(hasUrlIssues ? _urlIssueTextStyle(context) : null),
          ),
        ),
      ],
    );
  }
}

/// Widget which renders connection stats based on [call].
class _ConnectionStats extends StatelessWidget {
  const _ConnectionStats({required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _StatItem(
          icon: Icons.schedule,
          text:
              call.request?.time != null
                  ? NetLensConversionHelper.formatClockTime(call.request!.time)
                  : 'n/a',
        ),
        _StatItem(
          icon: Icons.timer_outlined,
          text: NetLensConversionHelper.formatTime(call.duration),
        ),
        _StatItem(
          icon: Icons.swap_vert,
          text:
              '${NetLensConversionHelper.formatBytes(call.request?.size ?? 0)} / '
              '${NetLensConversionHelper.formatBytes(call.response?.size ?? 0)}',
        ),
      ],
    );
  }
}

/// Single connection stat: an icon followed by a value.
class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Text style which marks URL parts as erroneous with a wavy underline.
TextStyle _urlIssueTextStyle(BuildContext context) {
  final Color color = getUrlIssueColor(context);
  return TextStyle(
    color: color,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.wavy,
    decorationColor: color,
  );
}
