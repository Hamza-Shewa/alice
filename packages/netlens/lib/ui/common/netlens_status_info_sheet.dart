import 'package:netlens/core/netlens_http_status.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_call_badges.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Shows bottom sheet which explains what HTTP [status] means.
Future<void> showNetLensStatusInfo({
  required BuildContext context,
  required int? status,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder:
        (_) => Directionality(
          textDirection: NetLensLanguage.textDirection,
          child: NetLensStatusInfoSheet(status: status),
        ),
  );
}

/// Content of the bottom sheet which explains HTTP [status].
class NetLensStatusInfoSheet extends StatelessWidget {
  const NetLensStatusInfoSheet({super.key, required this.status});

  final int? status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = NetLensTheme.getStatusColor(context, status);
    final NetLensHttpStatusInfo? info = NetLensHttpStatus.get(
      status: status,
      languageCode: NetLensLanguage.current.value,
    );
    final NetLensHttpStatusCategory category = NetLensHttpStatus.getCategory(
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
                  NetLensStatusPill.getStatusText(status),
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    info?.name ?? context.i18n(NetLensTranslationKey.unknown),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (category != NetLensHttpStatusCategory.unknown) ...[
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
                  context.i18n(NetLensTranslationKey.statusUnknownDescription),
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns translation key of [category] name.
  NetLensTranslationKey _getCategoryKey(NetLensHttpStatusCategory category) =>
      switch (category) {
        NetLensHttpStatusCategory.informational =>
          NetLensTranslationKey.statusCategoryInformational,
        NetLensHttpStatusCategory.success =>
          NetLensTranslationKey.statusCategorySuccess,
        NetLensHttpStatusCategory.redirection =>
          NetLensTranslationKey.statusCategoryRedirection,
        NetLensHttpStatusCategory.clientError =>
          NetLensTranslationKey.statusCategoryClientError,
        NetLensHttpStatusCategory.serverError =>
          NetLensTranslationKey.statusCategoryServerError,
        NetLensHttpStatusCategory.failed =>
          NetLensTranslationKey.statusCategoryFailed,
        NetLensHttpStatusCategory.unknown => NetLensTranslationKey.unknown,
      };
}
