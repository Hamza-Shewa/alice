import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/common/alice_url_issue_banner.dart';
import 'package:flutter/material.dart';

const int _endpointMaxLines = 2;
const double _statusBarWidth = 4;
const double _urlIssueBarWidth = 6;

/// Widget which renders one row in calls list view. It displays general
/// information about call.
class AliceCallListItemWidget extends StatelessWidget {
  const AliceCallListItemWidget(this.call, this.itemClickAction, {super.key});

  final AliceHttpCall call;
  final void Function(AliceHttpCall) itemClickAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color statusColor =
        call.loading
            ? AliceTheme.grey
            : AliceTheme.getStatusColor(context, call.response?.status);
    final List<AliceUrlIssue> urlIssues = AliceUrlValidator.validateCall(call);
    final bool hasUrlIssues = urlIssues.isNotEmpty;
    final Color urlIssueColor = getUrlIssueColor(context);

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
                  AliceMethodBadge(method: call.method),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Endpoint(call: call, hasUrlIssues: hasUrlIssues),
                  ),
                  const SizedBox(width: 10),
                  AliceStatusPill(call: call),
                ],
              ),
              const SizedBox(height: 6),
              _ServerAddress(call: call, hasUrlIssues: hasUrlIssues),
              if (hasUrlIssues) ...[
                const SizedBox(height: 10),
                AliceUrlIssueBanner(issues: urlIssues, compact: true),
              ],
              const SizedBox(height: 8),
              _ConnectionStats(call: call),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget which renders endpoint of the call.
class _Endpoint extends StatelessWidget {
  const _Endpoint({required this.call, required this.hasUrlIssues});

  final AliceHttpCall call;
  final bool hasUrlIssues;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      call.endpoint,
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

/// Widget which renders server address line.
class _ServerAddress extends StatelessWidget {
  const _ServerAddress({required this.call, required this.hasUrlIssues});

  final AliceHttpCall call;
  final bool hasUrlIssues;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          call.secure ? Icons.lock_outline : Icons.lock_open,
          color: AliceTheme.getStatusColor(context, call.secure ? 200 : 400),
          size: 14,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            call.server,
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

  final AliceHttpCall call;

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
                  ? AliceConversionHelper.formatClockTime(call.request!.time)
                  : 'n/a',
        ),
        _StatItem(
          icon: Icons.timer_outlined,
          text: AliceConversionHelper.formatTime(call.duration),
        ),
        _StatItem(
          icon: Icons.swap_vert,
          text:
              '${AliceConversionHelper.formatBytes(call.request?.size ?? 0)} / '
              '${AliceConversionHelper.formatBytes(call.response?.size ?? 0)}',
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
