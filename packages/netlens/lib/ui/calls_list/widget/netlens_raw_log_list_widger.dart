import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_logs_widget.dart';
import 'package:netlens/ui/calls_list/widget/netlens_error_logs_widget.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget which displays raw logs list (logs collected with ADB).
class NetLensRawLogListWidget extends StatelessWidget {
  const NetLensRawLogListWidget({
    required this.scrollController,
    required this.getRawLogs,
    super.key,
  });

  final ScrollController scrollController;
  final Future<String>? getRawLogs;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getRawLogs,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const NetLensErrorLogsWidget();
        }

        final logs = snapshot.data ?? '';
        if (logs.isEmpty) {
          return const NetLensEmptyLogsWidget();
        }

        return Scrollbar(
          thickness: 8,
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onLongPress:
                    () => _copyToClipboard(
                      context: context,
                      text: snapshot.data ?? '',
                    ),
                child: Text(
                  snapshot.data ?? '',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Copies provided text to clipboard and displays info about it.
  Future<void> _copyToClipboard({
    required BuildContext context,
    required String text,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.i18n(NetLensTranslationKey.logsCopied))),
      );
    }
  }
}
