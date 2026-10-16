import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Returns translated name of the side responsible for the failure.
String netLensIssueLabel(BuildContext context, NetLensIssueOrigin origin) =>
    context.i18n(switch (origin) {
      NetLensIssueOrigin.frontend => NetLensTranslationKey.issueFrontend,
      NetLensIssueOrigin.backend => NetLensTranslationKey.issueBackend,
      NetLensIssueOrigin.network => NetLensTranslationKey.issueNetwork,
    });

/// Returns icon which represents the side responsible for the failure.
IconData netLensIssueIcon(NetLensIssueOrigin origin) => switch (origin) {
  NetLensIssueOrigin.frontend => Icons.phone_android,
  NetLensIssueOrigin.backend => Icons.dns_outlined,
  NetLensIssueOrigin.network => Icons.wifi_off,
};

/// Returns translated explanation of [issue].
String netLensIssueReason(BuildContext context, NetLensIssue issue) {
  final String details = issue.details ?? '';
  return context
      .i18n(issue.reason)
      .replaceAll('[status]', details)
      .replaceAll('[error]', details)
      .trim();
}

/// Small flag which tells whether the failure is a frontend, backend or
/// network issue.
class NetLensIssueChip extends StatelessWidget {
  const NetLensIssueChip({super.key, required this.origin});

  final NetLensIssueOrigin origin;

  @override
  Widget build(BuildContext context) {
    final Color color = NetLensTheme.getIssueColor(context, origin);
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
              netLensIssueLabel(context, origin),
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
class NetLensIssueBanner extends StatelessWidget {
  const NetLensIssueBanner({super.key, required this.issue});

  final NetLensIssue issue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = NetLensTheme.getIssueColor(context, issue.origin);
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
            child: Icon(netLensIssueIcon(issue.origin), size: 20, color: color),
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
                        netLensIssueLabel(context, issue.origin),
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
                  netLensIssueReason(context, issue),
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
