import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_conversion_helper.dart';
import 'package:netlens/helper/netlens_graphql.dart';
import 'package:netlens/helper/netlens_timeline.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_state_widget.dart';
import 'package:netlens/ui/common/netlens_app_bar.dart';
import 'package:netlens/ui/common/netlens_call_badges.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_detail_widgets.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';
import 'package:netlens/ui/common/netlens_page.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_settings.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Waterfall of the latest calls: each call is a bar placed at its start
/// time, as long as it took. Calls which ran at the same time overlap.
class NetLensTimelinePage extends StatefulWidget {
  const NetLensTimelinePage({super.key, required this.core});

  final NetLensCore core;

  @override
  State<NetLensTimelinePage> createState() => _NetLensTimelinePageState();
}

class _NetLensTimelinePageState extends State<NetLensTimelinePage>
    with NetLensSettingsListenerMixin {
  @override
  Widget build(BuildContext context) {
    return NetLensPage(
      core: widget.core,
      child: Scaffold(
        appBar: NetLensAppBar(
          title: Text(
            '${context.i18n(NetLensTranslationKey.netLens)} - '
            '${context.i18n(NetLensTranslationKey.callsListTimeline)}',
          ),
          actions: [NetLensSettingsButton(core: widget.core)],
        ),
        body: StreamBuilder<List<NetLensHttpCall>>(
          stream: widget.core.callsStream,
          initialData: widget.core.getCalls(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<NetLensHttpCall>> snapshot,
          ) {
            final NetLensTimeline timeline = NetLensTimeline.from(
              snapshot.data ?? const [],
            );
            if (timeline.spans.isEmpty) {
              return NetLensEmptyStateWidget(
                icon: Icons.view_timeline_outlined,
                title: context.i18n(NetLensTranslationKey.timelineEmpty),
              );
            }
            return ScrollConfiguration(
              behavior: NetLensScrollBehavior(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: timeline.spans.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _Header(timeline: timeline);
                  }
                  final NetLensTimelineSpan span = timeline.spans[index - 1];
                  return _SpanRow(
                    key: ValueKey(span.call.id),
                    span: span,
                    length: timeline.length,
                    onTap:
                        () => NetLensNavigation.navigateToCallDetails(
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

  static const int _ticks = 2;

  final NetLensTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NetLensOutlinedCard(
            child: Text(
              context
                  .i18n(NetLensTranslationKey.timelineSummary)
                  .replaceAll('[count]', '${timeline.spans.length}')
                  .replaceAll(
                    '[duration]',
                    NetLensConversionHelper.formatTime(timeline.length),
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
              children: [
                for (int tick = 0; tick <= _ticks; tick++)
                  Expanded(
                    child: Text(
                      NetLensConversionHelper.formatTime(
                        timeline.length * tick ~/ _ticks,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign:
                          tick == 0
                              ? TextAlign.left
                              : tick == _ticks
                              ? TextAlign.right
                              : TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
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

  final NetLensTimelineSpan span;
  final int length;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NetLensHttpCall call = span.call;
    final Color color =
        call.loading
            ? NetLensTheme.grey
            : NetLensTheme.getStatusColor(context, call.response?.status);
    final String title = NetLensGraphQL.detect(call)?.title ?? call.endpoint;
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
                NetLensMethodBadge(method: call.method, fontSize: 10),
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
                      ? context.i18n(NetLensTranslationKey.callOverviewPending)
                      : NetLensConversionHelper.formatTime(span.duration),
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
