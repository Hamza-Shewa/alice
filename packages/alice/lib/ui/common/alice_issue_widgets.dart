import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Returns translated name of the side responsible for the failure.
String aliceIssueLabel(BuildContext context, AliceIssueOrigin origin) =>
    context.i18n(switch (origin) {
      AliceIssueOrigin.frontend => AliceTranslationKey.issueFrontend,
      AliceIssueOrigin.backend => AliceTranslationKey.issueBackend,
      AliceIssueOrigin.network => AliceTranslationKey.issueNetwork,
    });

/// Returns icon which represents the side responsible for the failure.
IconData aliceIssueIcon(AliceIssueOrigin origin) => switch (origin) {
  AliceIssueOrigin.frontend => Icons.phone_android,
  AliceIssueOrigin.backend => Icons.dns_outlined,
  AliceIssueOrigin.network => Icons.wifi_off,
};

/// Returns translated explanation of [issue].
String aliceIssueReason(BuildContext context, AliceIssue issue) {
  final String details = issue.details ?? '';
  return context
      .i18n(issue.reason)
      .replaceAll('[status]', details)
      .replaceAll('[error]', details)
      .trim();
}

/// Small flag which tells whether the failure is a frontend, backend or
/// network issue.
class AliceIssueChip extends StatelessWidget {
  const AliceIssueChip({super.key, required this.origin});

  final AliceIssueOrigin origin;

  @override
  Widget build(BuildContext context) {
    final Color color = AliceTheme.getIssueColor(context, origin);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              aliceIssueLabel(context, origin),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
  }
}

/// Card which explains who is most likely responsible for the failure and
/// why.
class AliceIssueBanner extends StatelessWidget {
  const AliceIssueBanner({super.key, required this.issue});

  final AliceIssue issue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = AliceTheme.getIssueColor(context, issue.origin);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(aliceIssueIcon(issue.origin), size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        aliceIssueLabel(context, issue.origin),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  aliceIssueReason(context, issue),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
