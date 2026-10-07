import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_state_widget.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Widget which renders error text for logs list.
class AliceErrorLogsWidget extends StatelessWidget {
  const AliceErrorLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AliceEmptyStateWidget(
      icon: Icons.error_outline,
      iconColor: AliceTheme.red,
      title: context.i18n(AliceTranslationKey.logsItemError),
    );
  }
}
