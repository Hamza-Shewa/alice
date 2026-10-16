import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Returns translated name of [outcome].
String netLensWatchOutcomeLabel(
  BuildContext context,
  NetLensWatchOutcome outcome,
) => context.i18n(switch (outcome) {
  NetLensWatchOutcome.success => NetLensTranslationKey.watcherOutcomeSuccess,
  NetLensWatchOutcome.failed => NetLensTranslationKey.watcherOutcomeFailed,
  NetLensWatchOutcome.serverDown =>
    NetLensTranslationKey.watcherOutcomeServerDown,
});

/// Returns icon which represents [outcome].
IconData netLensWatchOutcomeIcon(NetLensWatchOutcome outcome) =>
    switch (outcome) {
      NetLensWatchOutcome.success => Icons.check_circle_outline,
      NetLensWatchOutcome.failed => Icons.error_outline,
      NetLensWatchOutcome.serverDown => Icons.cloud_off_outlined,
    };

/// Returns color which represents [outcome], matching the colors of status
/// codes: success is green, failed orange and server down red.
Color netLensWatchOutcomeColor(
  BuildContext context,
  NetLensWatchOutcome outcome,
) => NetLensTheme.getStatusColor(context, switch (outcome) {
  NetLensWatchOutcome.success => 200,
  NetLensWatchOutcome.failed => 300,
  NetLensWatchOutcome.serverDown => 500,
});

/// Small chip with the result of a watched response field, for example
/// `type 2 · Failed`. It is displayed next to the HTTP status.
class NetLensWatchChip extends StatelessWidget {
  const NetLensWatchChip({super.key, required this.result});

  final NetLensWatchResult result;

  @override
  Widget build(BuildContext context) {
    final Color color = netLensWatchOutcomeColor(context, result.outcome);
    final Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(netLensWatchOutcomeIcon(result.outcome), size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${result.path} ${result.value} · '
              '${netLensWatchOutcomeLabel(context, result.outcome)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
    return result.meaning.isEmpty
        ? chip
        : Tooltip(message: result.meaning, child: chip);
  }
}

/// Box which explains the result of a watched response field, with the
/// meaning entered by the user.
class NetLensWatchResultBox extends StatelessWidget {
  const NetLensWatchResultBox({super.key, required this.result});

  final NetLensWatchResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = netLensWatchOutcomeColor(context, result.outcome);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(netLensWatchOutcomeIcon(result.outcome), size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.path} = ${result.value} · '
                  '${netLensWatchOutcomeLabel(context, result.outcome)}',
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (result.meaning.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(result.meaning, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
