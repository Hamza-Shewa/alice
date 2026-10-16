import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_state_widget.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Widget which renders error text for logs list.
class NetLensErrorLogsWidget extends StatelessWidget {
  const NetLensErrorLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NetLensEmptyStateWidget(
      icon: Icons.error_outline,
      iconColor: NetLensTheme.red,
      title: context.i18n(NetLensTranslationKey.logsItemError),
    );
  }
}
