import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_state_widget.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:flutter/material.dart';

/// Widget which renders empty text for logs list.
class NetLensEmptyLogsWidget extends StatelessWidget {
  const NetLensEmptyLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NetLensEmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: context.i18n(NetLensTranslationKey.logsEmpty),
    );
  }
}
