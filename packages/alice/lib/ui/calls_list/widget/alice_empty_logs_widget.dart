import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/widget/alice_empty_state_widget.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:flutter/material.dart';

/// Widget which renders empty text for logs list.
class AliceEmptyLogsWidget extends StatelessWidget {
  const AliceEmptyLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AliceEmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: context.i18n(AliceTranslationKey.logsEmpty),
    );
  }
}
