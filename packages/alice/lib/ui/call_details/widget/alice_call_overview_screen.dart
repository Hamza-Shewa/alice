import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/common/alice_url_issue_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen which displays call overview data, for example method, server.
class AliceCallOverviewScreen extends StatelessWidget {
  final AliceHttpCall call;

  const AliceCallOverviewScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final List<AliceUrlIssue> urlIssues = AliceUrlValidator.validateCall(call);
    final DateTime? started = call.request?.time;
    final DateTime? finished = call.loading ? null : call.response?.time;
    final String pending = context.i18n(
      AliceTranslationKey.callOverviewPending,
    );

    return ScrollConfiguration(
      behavior: AliceScrollBehavior(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (urlIssues.isNotEmpty) ...[
            AliceUrlIssueBanner(issues: urlIssues),
            const SizedBox(height: 16),
          ],
          _SummaryCard(call: call, hasUrlIssues: urlIssues.isNotEmpty),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.timer_outlined,
                  label: _label(
                    context,
                    AliceTranslationKey.callOverviewDuration,
                  ),
                  value:
                      call.loading
                          ? pending
                          : AliceConversionHelper.formatTime(call.duration),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.upload_outlined,
                  label: _label(
                    context,
                    AliceTranslationKey.callOverviewBytesSent,
                  ),
                  value: AliceConversionHelper.formatBytes(
                    call.request?.size ?? 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.download_outlined,
                  label: _label(
                    context,
                    AliceTranslationKey.callOverviewBytesReceived,
                  ),
                  value: AliceConversionHelper.formatBytes(
                    call.response?.size ?? 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: context.i18n(AliceTranslationKey.callOverviewTiming),
            rows: [
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewStarted),
                value:
                    started != null
                        ? AliceConversionHelper.formatDateTime(started)
                        : pending,
              ),
              _InfoRow(
                label: _label(
                  context,
                  AliceTranslationKey.callOverviewFinished,
                ),
                value:
                    finished != null
                        ? AliceConversionHelper.formatDateTime(finished)
                        : pending,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: context.i18n(AliceTranslationKey.callOverviewConnection),
            rows: [
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewMethod),
                value: call.method,
              ),
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewServer),
                value: call.server,
                hasError: urlIssues.isNotEmpty,
              ),
              _InfoRow(
                label: _label(
                  context,
                  AliceTranslationKey.callOverviewEndpoint,
                ),
                value: call.endpoint,
                hasError: urlIssues.isNotEmpty,
              ),
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewClient),
                value: call.client.isEmpty ? '-' : call.client,
              ),
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewSecure),
                value: context.i18n(
                  call.secure
                      ? AliceTranslationKey.callsListYes
                      : AliceTranslationKey.callsListNo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns translated label without trailing colon.
  static String _label(BuildContext context, AliceTranslationKey key) =>
      context.i18n(key).replaceFirst(RegExp(r':\s*$'), '');
}

/// Returns full URL of [call], built from server and endpoint when URI is
/// missing.
String _getUrl(AliceHttpCall call) {
  if (call.uri.isNotEmpty) {
    return call.uri;
  }
  return '${call.secure ? 'https' : 'http'}://${call.server}${call.endpoint}';
}

/// Card with method, status, full URL and connection chips.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.call, required this.hasUrlIssues});

  final AliceHttpCall call;
  final bool hasUrlIssues;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color urlIssueColor = getUrlIssueColor(context);
    final String url = _getUrl(call);

    return _OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AliceMethodBadge(method: call.method, fontSize: 14),
              const Spacer(),
              AliceStatusPill(call: call, fontSize: 15),
            ],
          ),
          const SizedBox(height: 14),
          SelectableText(
            url,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: hasUrlIssues ? urlIssueColor : theme.colorScheme.onSurface,
              decoration: hasUrlIssues ? TextDecoration.underline : null,
              decorationStyle: TextDecorationStyle.wavy,
              decorationColor: urlIssueColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoChip(
                icon: call.secure ? Icons.lock_outline : Icons.lock_open,
                text: call.secure ? 'HTTPS' : 'HTTP',
                color: AliceTheme.getStatusColor(
                  context,
                  call.secure ? 200 : 400,
                ),
              ),
              if (call.client.isNotEmpty)
                _InfoChip(
                  icon: Icons.settings_ethernet,
                  text: call.client,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              _CopyButton(url: url),
            ],
          ),
        ],
      ),
    );
  }
}

/// Button which copies call URL to clipboard.
class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: const Icon(Icons.copy, size: 16),
      label: Text(context.i18n(AliceTranslationKey.callOverviewCopyUrl)),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: url));
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                context.i18n(AliceTranslationKey.callOverviewCopied),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
    );
  }
}

/// Small rounded label with an icon.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile which displays one key number, for example duration.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color mutedColor = theme.colorScheme.onSurfaceVariant;
    return _OutlinedCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: mutedColor),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}

/// Titled group of label/value rows.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color dividerColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.08,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _OutlinedCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int index = 0; index < rows.length; index++) ...[
                if (index > 0) Divider(height: 1, color: dividerColor),
                rows[index],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Single label/value row. Value can be selected and copied.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.hasError = false,
  });

  final String label;
  final String value;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color errorColor = getUrlIssueColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: hasError ? errorColor : theme.colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded container with a subtle fill and outline.
class _OutlinedCard extends StatelessWidget {
  const _OutlinedCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
