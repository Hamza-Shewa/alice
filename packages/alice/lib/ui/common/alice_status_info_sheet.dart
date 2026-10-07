import 'package:alice/core/alice_http_status.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Shows bottom sheet which explains what HTTP [status] means.
Future<void> showAliceStatusInfo({
  required BuildContext context,
  required int? status,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => AliceStatusInfoSheet(status: status),
  );
}

/// Content of the bottom sheet which explains HTTP [status].
class AliceStatusInfoSheet extends StatelessWidget {
  const AliceStatusInfoSheet({super.key, required this.status});

  final int? status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = AliceTheme.getStatusColor(context, status);
    final AliceHttpStatusInfo? info = AliceHttpStatus.get(
      status: status,
      languageCode: Localizations.maybeLocaleOf(context)?.languageCode ?? 'en',
    );
    final AliceHttpStatusCategory category = AliceHttpStatus.getCategory(
      status,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  AliceStatusPill.getStatusText(status),
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    info?.name ?? context.i18n(AliceTranslationKey.unknown),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (category != AliceHttpStatusCategory.unknown) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.i18n(_getCategoryKey(category)),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              info?.description ??
                  context.i18n(AliceTranslationKey.statusUnknownDescription),
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns translation key of [category] name.
  AliceTranslationKey _getCategoryKey(
    AliceHttpStatusCategory category,
  ) => switch (category) {
    AliceHttpStatusCategory.informational =>
      AliceTranslationKey.statusCategoryInformational,
    AliceHttpStatusCategory.success =>
      AliceTranslationKey.statusCategorySuccess,
    AliceHttpStatusCategory.redirection =>
      AliceTranslationKey.statusCategoryRedirection,
    AliceHttpStatusCategory.clientError =>
      AliceTranslationKey.statusCategoryClientError,
    AliceHttpStatusCategory.serverError =>
      AliceTranslationKey.statusCategoryServerError,
    AliceHttpStatusCategory.failed => AliceTranslationKey.statusCategoryFailed,
    AliceHttpStatusCategory.unknown => AliceTranslationKey.unknown,
  };
}
