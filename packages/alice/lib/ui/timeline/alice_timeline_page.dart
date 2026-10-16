import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_graphql.dart';
import 'package:alice/helper/alice_timeline.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_state_widget.dart';
import 'package:alice/ui/common/alice_app_bar.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/ui/common/alice_settings.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Waterfall of the latest calls: each call is a bar placed at its start
/// time, as long as it took. Calls which ran at the same time overlap.
class AliceTimelinePage extends StatefulWidget {
  const AliceTimelinePage({super.key, required this.core});

  final AliceCore core;

  @override
  State<AliceTimelinePage> createState() => _AliceTimelinePageState();
}

class _AliceTimelinePageState extends State<AliceTimelinePage>
    with AliceSettingsListenerMixin {
  @override
  Widget build(BuildContext context) {
    return AlicePage(
      core: widget.core,
      child: Scaffold(
        appBar: AliceAppBar(
          title: Text(
            '${context.i18n(AliceTranslationKey.alice)} - '
            '${context.i18n(AliceTranslationKey.callsListTimeline)}',
          ),
          actions: [AliceSettingsButton(core: widget.core)],
        ),
        body: StreamBuilder<List<AliceHttpCall>>(
          stream: widget.core.callsStream,
          initialData: widget.core.getCalls(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<AliceHttpCall>> snapshot,
          ) {
            final AliceTimeline timeline = AliceTimeline.from(
              snapshot.data ?? const [],
            );
            if (timeline.spans.isEmpty) {
              return AliceEmptyStateWidget(
                icon: Icons.view_timeline_outlined,
                title: context.i18n(AliceTranslationKey.timelineEmpty),
              );
            }
            return ScrollConfiguration(
              behavior: AliceScrollBehavior(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: timeline.spans.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _Header(timeline: timeline);
                  }
                  final AliceTimelineSpan span = timeline.spans[index - 1];
                  return _SpanRow(
                    key: ValueKey(span.call.id),
                    span: span,
                    length: timeline.length,
                    onTap:
                        () => AliceNavigation.navigateToCallDetails(
                          call: span.call,
                          core: widget.core,
                        ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Summary of the timeline and its time axis.
class _Header extends StatelessWidget {
  const _Header({required this.timeline});

  static const int _ticks = 4;

  final AliceTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AliceOutlinedCard(
            child: Text(
              context
                  .i18n(AliceTranslationKey.timelineSummary)
                  .replaceAll('[count]', '${timeline.spans.length}')
                  .replaceAll(
                    '[duration]',
                    AliceConversionHelper.formatTime(timeline.length),
                  )
                  .replaceAll('[concurrency]', '${timeline.maxConcurrency}'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          // Time always runs left to right, also in RTL layouts.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int tick = 0; tick <= _ticks; tick++)
                  Text(
                    AliceConversionHelper.formatTime(
                      timeline.length * tick ~/ _ticks,
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 1, color: muted.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}

/// One call: its name and duration, and a bar on the time axis.
class _SpanRow extends StatelessWidget {
  const _SpanRow({
    super.key,
    required this.span,
    required this.length,
    required this.onTap,
  });

  static const double _barHeight = 8;
  static const double _minBarWidth = 3;

  final AliceTimelineSpan span;
  final int length;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AliceHttpCall call = span.call;
    final Color color =
        call.loading
            ? AliceTheme.grey
            : AliceTheme.getStatusColor(context, call.response?.status);
    final String title = AliceGraphQL.detect(call)?.title ?? call.endpoint;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AliceMethodBadge(method: call.method, fontSize: 10),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  call.loading
                      ? context.i18n(AliceTranslationKey.callOverviewPending)
                      : AliceConversionHelper.formatTime(span.duration),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth;
                  final double scale = length == 0 ? 0 : width / length;
                  final double barWidth = (span.duration * scale).clamp(
                    _minBarWidth,
                    width,
                  );
                  final double start = (span.start * scale).clamp(
                    0,
                    width - barWidth,
                  );
                  return Container(
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.06,
                      ),
                      borderRadius: BorderRadius.circular(_barHeight / 2),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: start,
                          width: barWidth,
                          top: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: color.withValues(
                                alpha: call.loading ? 0.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                _barHeight / 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
