import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Returns translated name of [outcome].
String aliceWatchOutcomeLabel(
  BuildContext context,
  AliceWatchOutcome outcome,
) => context.i18n(switch (outcome) {
  AliceWatchOutcome.success => AliceTranslationKey.watcherOutcomeSuccess,
  AliceWatchOutcome.failed => AliceTranslationKey.watcherOutcomeFailed,
  AliceWatchOutcome.serverDown => AliceTranslationKey.watcherOutcomeServerDown,
});

/// Returns icon which represents [outcome].
IconData aliceWatchOutcomeIcon(AliceWatchOutcome outcome) => switch (outcome) {
  AliceWatchOutcome.success => Icons.check_circle_outline,
  AliceWatchOutcome.failed => Icons.error_outline,
  AliceWatchOutcome.serverDown => Icons.cloud_off_outlined,
};

/// Returns color which represents [outcome], matching the colors of status
/// codes: success is green, failed orange and server down red.
Color aliceWatchOutcomeColor(BuildContext context, AliceWatchOutcome outcome) =>
    AliceTheme.getStatusColor(context, switch (outcome) {
      AliceWatchOutcome.success => 200,
      AliceWatchOutcome.failed => 300,
      AliceWatchOutcome.serverDown => 500,
    });

/// Small chip with the result of a watched response field, for example
/// `type 2 · Failed`. It is displayed next to the HTTP status.
class AliceWatchChip extends StatelessWidget {
  const AliceWatchChip({super.key, required this.result});

  final AliceWatchResult result;

  @override
  Widget build(BuildContext context) {
    final Color color = aliceWatchOutcomeColor(context, result.outcome);
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
          Icon(aliceWatchOutcomeIcon(result.outcome), size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${result.path} ${result.value} · '
              '${aliceWatchOutcomeLabel(context, result.outcome)}',
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
class AliceWatchResultBox extends StatelessWidget {
  const AliceWatchResultBox({super.key, required this.result});

  final AliceWatchResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = aliceWatchOutcomeColor(context, result.outcome);
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
          Icon(aliceWatchOutcomeIcon(result.outcome), size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.path} = ${result.value} · '
                  '${aliceWatchOutcomeLabel(context, result.outcome)}',
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
