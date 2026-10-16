import 'package:netlens/core/netlens_logger.dart';
import 'package:netlens/ui/calls_list/widget/netlens_empty_logs_widget.dart';
import 'package:netlens/ui/calls_list/widget/netlens_log_list_widget.dart';
import 'package:netlens/ui/calls_list/widget/netlens_raw_log_list_widger.dart';
import 'package:flutter/material.dart';

/// Screen hosted in calls list which displays logs list.
class NetLensLogsScreen extends StatelessWidget {
  const NetLensLogsScreen({
    super.key,
    required this.scrollController,
    this.netLensLogger,
    this.isAndroidRawLogsEnabled = false,
  });

  final ScrollController scrollController;
  final NetLensLogger? netLensLogger;
  final bool isAndroidRawLogsEnabled;

  @override
  Widget build(BuildContext context) =>
      netLensLogger != null
          ? isAndroidRawLogsEnabled
              ? NetLensRawLogListWidget(
                scrollController: scrollController,
                getRawLogs: netLensLogger?.getAndroidRawLogs(),
              )
              : NetLensLogListWidget(
                logsStream: netLensLogger?.logsStream,
                initialLogs: netLensLogger?.logs,
                scrollController: scrollController,
              )
          : const NetLensEmptyLogsWidget();
}
