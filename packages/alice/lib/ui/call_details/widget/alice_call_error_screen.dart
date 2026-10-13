import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_state_widget.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/common/alice_url_issue_banner.dart';
import 'package:flutter/material.dart';

/// Call error screen which displays info on HTTP call error.
class AliceCallErrorScreen extends StatelessWidget {
  const AliceCallErrorScreen({super.key, required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final dynamic error = call.error?.error;
    final StackTrace? stackTrace = call.error?.stackTrace;

    if (call.error == null) {
      return AliceEmptyStateWidget(
        icon: Icons.check_circle_outline,
        iconColor: AliceTheme.getStatusColor(context, 200),
        title: context.i18n(AliceTranslationKey.callErrorScreenEmpty),
      );
    }

    final String message =
        error != null
            ? error.toString()
            : context.i18n(AliceTranslationKey.callErrorScreenErrorEmpty);

    return SelectionArea(
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            AliceDetailSection(
              title: aliceStripColon(
                context.i18n(AliceTranslationKey.callErrorScreenError),
              ),
              children: [
                if (error != null)
                  AliceGroup(
                    title: context.i18n(
                      AliceTranslationKey.callErrorScreenType,
                    ),
                    child: _ErrorTypeChip(type: error.runtimeType.toString()),
                  ),
                AliceCodeBlock(text: message, isError: true),
              ],
            ),
            if (stackTrace != null) ...[
              const SizedBox(height: 20),
              AliceDetailSection(
                title: aliceStripColon(
                  context.i18n(AliceTranslationKey.callErrorScreenStacktrace),
                ),
                children: [AliceCodeBlock(text: stackTrace.toString())],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rounded label with the runtime type of the error.
class _ErrorTypeChip extends StatelessWidget {
  const _ErrorTypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final Color color = getUrlIssueColor(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                type,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
