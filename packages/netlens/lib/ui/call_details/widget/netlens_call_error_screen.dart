import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_state_widget.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_detail_widgets.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:netlens/ui/common/netlens_url_issue_banner.dart';
import 'package:flutter/material.dart';

/// Call error screen which displays info on HTTP call error.
class NetLensCallErrorScreen extends StatelessWidget {
  const NetLensCallErrorScreen({super.key, required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    final dynamic error = call.error?.error;
    final StackTrace? stackTrace = call.error?.stackTrace;

    if (call.error == null) {
      return NetLensEmptyStateWidget(
        icon: Icons.check_circle_outline,
        iconColor: NetLensTheme.getStatusColor(context, 200),
        title: context.i18n(NetLensTranslationKey.callErrorScreenEmpty),
      );
    }

    final String message =
        error != null
            ? error.toString()
            : context.i18n(NetLensTranslationKey.callErrorScreenErrorEmpty);

    return SelectionArea(
      child: ScrollConfiguration(
        behavior: NetLensScrollBehavior(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            NetLensDetailSection(
              title: netLensStripColon(
                context.i18n(NetLensTranslationKey.callErrorScreenError),
              ),
              children: [
                if (error != null)
                  NetLensGroup(
                    title: context.i18n(
                      NetLensTranslationKey.callErrorScreenType,
                    ),
                    child: _ErrorTypeChip(type: error.runtimeType.toString()),
                  ),
                NetLensCodeBlock(text: message, isError: true),
              ],
            ),
            if (stackTrace != null) ...[
              const SizedBox(height: 20),
              NetLensDetailSection(
                title: netLensStripColon(
                  context.i18n(NetLensTranslationKey.callErrorScreenStacktrace),
                ),
                children: [NetLensCodeBlock(text: stackTrace.toString())],
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
