import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_call_statistics.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_endpoint_statistics.dart';
import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_app_bar.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:alice/ui/common/alice_issue_widgets.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/ui/common/alice_settings.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// General stats page for currently caught HTTP calls. It updates while new
/// calls arrive.
class AliceStatsPage extends StatefulWidget {
  const AliceStatsPage(this.aliceCore, {super.key});

  final AliceCore aliceCore;

  @override
  State<AliceStatsPage> createState() => _AliceStatsPageState();
}

class _AliceStatsPageState extends State<AliceStatsPage>
    with AliceSettingsListenerMixin {
  @override
  Widget build(BuildContext context) {
    return AlicePage(
      core: widget.aliceCore,
      child: Builder(
        builder:
            (BuildContext context) => Scaffold(
              appBar: AliceAppBar(
                title: Text(
                  '${context.i18n(AliceTranslationKey.alice)} - '
                  '${context.i18n(AliceTranslationKey.statsTitle)}',
                ),
                actions: [AliceSettingsButton(core: widget.aliceCore)],
              ),
              body: StreamBuilder<List<AliceHttpCall>>(
                stream: widget.aliceCore.callsStream,
                initialData: widget.aliceCore.getCalls(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<AliceHttpCall>> snapshot,
                ) {
                  final List<AliceHttpCall> calls =
                      snapshot.data ?? widget.aliceCore.getCalls();
                  final AliceCallStatistics stats = AliceCallStatistics.from(
                    calls,
                  );
                  final List<AliceEndpointTiming> slowest =
                      AliceEndpointStatistics.slowest(calls);
                  return ScrollConfiguration(
                    behavior: AliceScrollBehavior(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        _StatusCard(stats: stats),
                        const SizedBox(height: 20),
                        _IssuesSection(stats: stats),
                        const SizedBox(height: 20),
                        _TrafficSection(stats: stats),
                        const SizedBox(height: 20),
                        _TimingSection(stats: stats),
                        if (slowest.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _SlowestSection(timings: slowest),
                        ],
                        if (stats.methods.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _MethodsSection(stats: stats),
                        ],
                        const SizedBox(height: 20),
                        _SecuritySection(stats: stats),
                      ],
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }
}

/// Translated label without the trailing colon.
String _label(BuildContext context, AliceTranslationKey key) =>
    aliceStripColon(context.i18n(key));

/// Total number of calls, success rate and the split of calls by result.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.stats});

  final AliceCallStatistics stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int? rate = stats.successRate;
    final Color rateColor = AliceTheme.getStatusColor(
      context,
      rate == null || rate >= 90 ? 200 : (rate >= 70 ? 300 : 500),
    );
    final List<_Segment> segments = [
      _Segment(
        label: _label(context, AliceTranslationKey.statsSuccessRequests),
        count: stats.success,
        color: AliceTheme.getStatusColor(context, 200),
      ),
      _Segment(
        label: _label(context, AliceTranslationKey.statsRedirectionRequests),
        count: stats.redirection,
        color: AliceTheme.getStatusColor(context, 300),
      ),
      _Segment(
        label: _label(context, AliceTranslationKey.statsErrorRequests),
        count: stats.error,
        color: AliceTheme.getStatusColor(context, 500),
      ),
      _Segment(
        label: _label(context, AliceTranslationKey.statsPendingRequests),
        count: stats.pending,
        color: AliceTheme.grey,
      ),
    ];

    return AliceOutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.total}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      _label(context, AliceTranslationKey.statsTotalRequests),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (rate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$rate%',
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: rateColor,
                      ),
                    ),
                    Text(
                      context.i18n(AliceTranslationKey.statsSuccessRate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          _StackedBar(segments: segments, total: stats.total),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final _Segment segment in segments)
                _LegendItem(segment: segment),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment {
  const _Segment({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

/// Horizontal bar split into colored parts proportional to their counts.
class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.segments, required this.total});

  final List<_Segment> segments;
  final int total;

  @override
  Widget build(BuildContext context) {
    final Color track = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.08);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child:
            total == 0
                ? ColoredBox(color: track)
                : Row(
                  children: [
                    for (final _Segment segment in segments)
                      if (segment.count > 0)
                        Expanded(
                          flex: segment.count,
                          child: ColoredBox(color: segment.color),
                        ),
                  ],
                ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.segment});

  final _Segment segment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            segment.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${segment.count}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Number of failed calls per side responsible for the failure.
class _IssuesSection extends StatelessWidget {
  const _IssuesSection({required this.stats});

  final AliceCallStatistics stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.statsSectionIssues),
      children: [
        if (stats.issueCount == 0)
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AliceTheme.getStatusColor(context, 200),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.i18n(AliceTranslationKey.statsNoIssues),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final AliceIssueOrigin origin
                    in AliceIssueOrigin.values) ...[
                  if (origin != AliceIssueOrigin.values.first)
                    const SizedBox(width: 8),
                  Expanded(
                    child: _IssueTile(
                      origin: origin,
                      count: stats.issues[origin] ?? 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({required this.origin, required this.count});

  final AliceIssueOrigin origin;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color =
        count == 0
            ? theme.colorScheme.onSurfaceVariant
            : AliceTheme.getIssueColor(context, origin);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: count == 0 ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(aliceIssueIcon(origin), size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            aliceIssueLabel(context, origin),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Bytes sent and received.
class _TrafficSection extends StatelessWidget {
  const _TrafficSection({required this.stats});

  final AliceCallStatistics stats;

  @override
  Widget build(BuildContext context) {
    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.statsSectionTraffic),
      children: [
        _TileRow(
          tiles: [
            _Tile(
              icon: Icons.upload_outlined,
              label: _label(context, AliceTranslationKey.statsBytesSent),
              value: AliceConversionHelper.formatBytes(stats.bytesSent),
            ),
            _Tile(
              icon: Icons.download_outlined,
              label: _label(context, AliceTranslationKey.statsBytesReceived),
              value: AliceConversionHelper.formatBytes(stats.bytesReceived),
            ),
          ],
        ),
      ],
    );
  }
}

/// Average, slowest and fastest call.
class _TimingSection extends StatelessWidget {
  const _TimingSection({required this.stats});

  final AliceCallStatistics stats;

  @override
  Widget build(BuildContext context) {
    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.statsSectionTiming),
      children: [
        _TileRow(
          tiles: [
            _Tile(
              icon: Icons.timer_outlined,
              label: _label(
                context,
                AliceTranslationKey.statsAverageRequestTime,
              ),
              value: AliceConversionHelper.formatTime(stats.averageTime),
            ),
            _Tile(
              icon: Icons.speed,
              label: _label(context, AliceTranslationKey.statsMaxRequestTime),
              value: AliceConversionHelper.formatTime(stats.maxTime),
            ),
            _Tile(
              icon: Icons.bolt,
              label: _label(context, AliceTranslationKey.statsMinRequestTime),
              value: AliceConversionHelper.formatTime(stats.minTime),
            ),
          ],
        ),
      ],
    );
  }
}

/// Endpoints with the longest response times: median, 95th percentile and
/// longest call.
class _SlowestSection extends StatelessWidget {
  const _SlowestSection({required this.timings});

  final List<AliceEndpointTiming> timings;

  @override
  Widget build(BuildContext context) {
    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.statsSectionSlowest),
      children: [
        for (final AliceEndpointTiming timing in timings)
          _EndpointTimingRow(timing: timing),
      ],
    );
  }
}

class _EndpointTimingRow extends StatelessWidget {
  const _EndpointTimingRow({required this.timing});

  final AliceEndpointTiming timing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final TextStyle? valueStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final TextStyle? labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: muted,
    );
    Widget metric(String label, int value) => Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label ', style: labelStyle),
          TextSpan(
            text: AliceConversionHelper.formatTime(value),
            style: valueStyle,
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AliceMethodBadge(method: timing.method, fontSize: 10),
            const SizedBox(width: 8),
            Expanded(
              child: AliceLtrText(
                timing.path,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            metric('p50', timing.p50),
            metric('p95', timing.p95),
            metric('max', timing.max),
            Text(
              context
                  .i18n(AliceTranslationKey.statsEndpointCalls)
                  .replaceAll('[count]', '${timing.count}'),
              style: labelStyle,
            ),
            if (timing.failures > 0)
              Text(
                context
                    .i18n(AliceTranslationKey.statsEndpointFailures)
                    .replaceAll('[count]', '${timing.failures}'),
                style: labelStyle?.copyWith(
                  color: AliceTheme.getStatusColor(context, 500),
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Row of tiles with the same height.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.tiles});

  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            textDirection: TextDirection.ltr,
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
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

/// Number of calls per HTTP method.
class _MethodsSection extends StatelessWidget {
  const _MethodsSection({required this.stats});

  final AliceCallStatistics stats;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> methods =
        stats.methods.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final int max = methods.first.value;
    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.statsSectionMethods),
      children: [
        for (final MapEntry<String, int> method in methods)
          _BarRow(
            label: method.key,
            count: method.value,
            max: max,
            color: AliceTheme.lightRed,
          ),
      ],
    );
  }
}

/// HTTPS and HTTP calls.
class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.stats});

  final AliceCallStatistics stats;

  @override
  Widget build(BuildContext context) {
    final int max =
        stats.secured > stats.unsecured ? stats.secured : stats.unsecured;
    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.statsSectionSecurity),
      children: [
        _BarRow(
          label: 'HTTPS',
          count: stats.secured,
          max: max,
          color: AliceTheme.getStatusColor(context, 200),
        ),
        _BarRow(
          label: 'HTTP',
          count: stats.unsecured,
          max: max,
          color: AliceTheme.getStatusColor(context, 500),
        ),
      ],
    );
  }
}

/// Label, a bar proportional to [count] and the count itself.
class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.count,
    required this.max,
    required this.color,
  });

  final String label;
  final int count;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            textDirection: TextDirection.ltr,
            textAlign:
                Directionality.of(context) == TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.left,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                FractionallySizedBox(
                  widthFactor: max == 0 ? 0 : count / max,
                  child: Container(height: 10, color: color),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
