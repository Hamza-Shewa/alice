import 'package:netlens/helper/netlens_conversion_helper.dart';
import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_form_data_file.dart';
import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_call_badges.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_detail_widgets.dart';
import 'package:netlens/ui/common/netlens_issue_widgets.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_watcher_widgets.dart';
import 'package:netlens/utils/netlens_parser.dart';
import 'package:flutter/material.dart';

/// Screen which displays information about call request: summary, query
/// parameters, form data, headers and body.
class NetLensCallRequestScreen extends StatelessWidget {
  const NetLensCallRequestScreen({super.key, required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    final NetLensHttpRequest? request = call.request;
    final NetLensIssue? issue = NetLensIssueAnalyzer.analyze(call);
    final Map<String, dynamic> headers = request?.headers ?? const {};
    final Map<String, dynamic> queryParameters =
        request?.queryParameters ?? const {};
    final List<NetLensFormDataField> formFields = request?.formDataFields ?? [];
    final List<NetLensFormDataFile> formFiles = request?.formDataFiles ?? [];
    final String? rawContentType = request?.contentType;
    final String? contentType =
        (rawContentType != null && rawContentType.trim().isNotEmpty)
            ? rawContentType
            : NetLensParser.tryGetContentType(request?.headers);

    return SelectionArea(
      child: ScrollConfiguration(
        behavior: NetLensScrollBehavior(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (issue != null) ...[
              NetLensIssueBanner(issue: issue),
              const SizedBox(height: 12),
            ],
            _RequestSummary(call: call, contentType: contentType),
            if (queryParameters.isNotEmpty) ...[
              const SizedBox(height: 12),
              NetLensCollapsibleSection(
                icon: Icons.tune,
                title: netLensStripColon(
                  context.i18n(
                    NetLensTranslationKey.callRequestQueryParameters,
                  ),
                ),
                count: queryParameters.length,
                child: NetLensKeyValueList(
                  values: queryParameters.map(
                    (String key, dynamic value) => MapEntry(key, '$value'),
                  ),
                ),
              ),
            ],
            if (formFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              NetLensCollapsibleSection(
                icon: Icons.dynamic_form_outlined,
                title: netLensStripColon(
                  context.i18n(NetLensTranslationKey.callRequestFormDataFields),
                ),
                count: formFields.length,
                child: NetLensKeyValueList(
                  values: {
                    for (final NetLensFormDataField field in formFields)
                      field.name: field.value,
                  },
                ),
              ),
            ],
            if (formFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              NetLensCollapsibleSection(
                icon: Icons.attach_file,
                title: netLensStripColon(
                  context.i18n(NetLensTranslationKey.callRequestFormDataFiles),
                ),
                count: formFiles.length,
                child: NetLensKeyValueList(
                  values: {
                    for (final NetLensFormDataFile file in formFiles)
                      file.fileName ?? '-':
                          '${file.contentType}, '
                          '${NetLensConversionHelper.formatBytes(file.length)}',
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            NetLensCollapsibleSection(
              icon: Icons.list_alt,
              title: netLensStripColon(
                context.i18n(NetLensTranslationKey.callRequestHeaders),
              ),
              count: headers.length,
              initiallyExpanded: headers.length <= 8,
              action:
                  headers.isEmpty
                      ? null
                      : NetLensCopyIconButton(
                        text: headers.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join('\n'),
                      ),
              child: NetLensKeyValueList(
                values: headers.map(
                  (String key, dynamic value) => MapEntry(key, '$value'),
                ),
                emptyText: context.i18n(
                  NetLensTranslationKey.callRequestHeadersEmpty,
                ),
              ),
            ),
            const SizedBox(height: 12),
            NetLensCollapsibleSection(
              icon: Icons.data_object,
              title: netLensStripColon(
                context.i18n(NetLensTranslationKey.callRequestBody),
              ),
              child: NetLensFormattedBodyBlock(
                body: request?.body,
                contentType: contentType,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card with method, time, size and content type of the request.
class _RequestSummary extends StatelessWidget {
  const _RequestSummary({required this.call, required this.contentType});

  final NetLensHttpCall call;
  final String? contentType;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final DateTime? time = call.request?.time;
    final NetLensWatchResult? watch = NetLensWatcher.instance.evaluate(call);
    return NetLensOutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetLensMethodBadge(method: call.method, fontSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: NetLensLtrText(
                  call.endpoint,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NetLensInfoChip(
                icon: Icons.schedule,
                text:
                    time != null
                        ? NetLensConversionHelper.formatDateTime(time)
                        : '-',
                color: muted,
              ),
              NetLensInfoChip(
                icon: Icons.upload_outlined,
                text: NetLensConversionHelper.formatBytes(
                  call.request?.size ?? 0,
                ),
                color: muted,
              ),
              if (contentType != null)
                NetLensInfoChip(
                  icon: Icons.description_outlined,
                  text: contentType!,
                  color: muted,
                ),
              if (watch != null) NetLensWatchChip(result: watch),
            ],
          ),
        ],
      ),
    );
  }
}
