import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Banner which warns about mistakes in request URL, for example a port
/// written with a dot or a missing `/` between base URL and path.
class AliceUrlIssueBanner extends StatelessWidget {
  const AliceUrlIssueBanner({
    super.key,
    required this.issues,
    this.compact = false,
  });

  final List<AliceUrlIssue> issues;

  /// When true, only the first issue is described and the rest are counted.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color color = getUrlIssueColor(context);
    final List<AliceUrlIssue> shownIssues =
        compact ? issues.take(1).toList() : issues;
    final int hiddenCount = issues.length - shownIssues.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.i18n(AliceTranslationKey.urlIssueTitle).toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          for (final AliceUrlIssue issue in shownIssues)
            _IssueDescription(issue: issue, color: color),
          if (hiddenCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                context
                    .i18n(AliceTranslationKey.urlIssueMore)
                    .replaceAll('[count]', '$hiddenCount'),
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

/// Returns color used to highlight URL issues.
Color getUrlIssueColor(BuildContext context) =>
    AliceTheme.getStatusColor(context, -1);

/// Single URL issue: what is wrong and, when known, the corrected URL.
class _IssueDescription extends StatelessWidget {
  const _IssueDescription({required this.issue, required this.color});

  final AliceUrlIssue issue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.i18n(_getMessageKey(issue.type)),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (issue.suggestion != null) ...[
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${context.i18n(AliceTranslationKey.urlIssueSuggestion)} ',
                  ),
                  TextSpan(
                    text: issue.suggestion,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Returns translation key describing issue of [type].
  AliceTranslationKey _getMessageKey(AliceUrlIssueType type) => switch (type) {
    AliceUrlIssueType.portWithDot => AliceTranslationKey.urlIssuePortWithDot,
    AliceUrlIssueType.missingSlashAfterPort =>
      AliceTranslationKey.urlIssueMissingSlashAfterPort,
    AliceUrlIssueType.missingSlashAfterHost =>
      AliceTranslationKey.urlIssueMissingSlashAfterHost,
    AliceUrlIssueType.missingSlashAfterVersion =>
      AliceTranslationKey.urlIssueMissingSlashAfterVersion,
    AliceUrlIssueType.invalidIp => AliceTranslationKey.urlIssueInvalidIp,
    AliceUrlIssueType.doubleSlash => AliceTranslationKey.urlIssueDoubleSlash,
    AliceUrlIssueType.whitespace => AliceTranslationKey.urlIssueWhitespace,
    AliceUrlIssueType.missingScheme =>
      AliceTranslationKey.urlIssueMissingScheme,
  };
}
