import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
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
                  _MethodBadge(method: call.method),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Endpoint(call: call, hasUrlIssues: hasUrlIssues),
                  ),
                  const SizedBox(width: 10),
                  _ResponseStatus(call: call, color: statusColor),
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

/// Widget which renders the HTTP method as a compact badge.
class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 52),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
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

/// Widget which renders response status as a colored pill, or a progress
/// indicator while the call is still in progress.
class _ResponseStatus extends StatelessWidget {
  const _ResponseStatus({required this.call, required this.color});

  final AliceHttpCall call;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (call.loading) {
      return const Padding(
        padding: EdgeInsets.all(2),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AliceTheme.lightRed),
          ),
        ),
      );
    }
    if (call.response == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatus(call.response!),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  /// Get status based on [response].
  String _getStatus(AliceHttpResponse response) => switch (response.status) {
    -1 => 'ERR',
    0 => '???',
    _ => '${response.status}',
  };
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
                  ? _formatTime(call.request!.time)
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

  /// Formats call time as HH:mm:ss.SSS.
  String _formatTime(DateTime time) =>
      '${formatTimeUnit(time.hour)}:'
      '${formatTimeUnit(time.minute)}:'
      '${formatTimeUnit(time.second)}.'
      '${time.millisecond.toString().padLeft(3, '0')}';

  /// Format one of time units.
  String formatTimeUnit(int timeUnit) => timeUnit.toString().padLeft(2, '0');
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
