import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:alice/ui/common/alice_issue_widgets.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:flutter/material.dart';

/// Screen which displays information about call request: summary, query
/// parameters, form data, headers and body.
class AliceCallRequestScreen extends StatelessWidget {
  const AliceCallRequestScreen({super.key, required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final AliceHttpRequest? request = call.request;
    final AliceIssue? issue = AliceIssueAnalyzer.analyze(call);
    final Map<String, dynamic> headers = request?.headers ?? const {};
    final Map<String, dynamic> queryParameters =
        request?.queryParameters ?? const {};
    final List<AliceFormDataField> formFields = request?.formDataFields ?? [];
    final List<AliceFormDataFile> formFiles = request?.formDataFiles ?? [];
    final String? contentType = AliceParser.getContentType(
      context: context,
      headers: request?.headers,
    );

    return ScrollConfiguration(
      behavior: AliceScrollBehavior(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (issue != null) ...[
            AliceIssueBanner(issue: issue),
            const SizedBox(height: 12),
          ],
          _RequestSummary(call: call, contentType: contentType),
          if (queryParameters.isNotEmpty) ...[
            const SizedBox(height: 12),
            AliceCollapsibleSection(
              icon: Icons.tune,
              title: aliceStripColon(
                context.i18n(AliceTranslationKey.callRequestQueryParameters),
              ),
              count: queryParameters.length,
              child: AliceKeyValueList(
                values: queryParameters.map(
                  (String key, dynamic value) => MapEntry(key, '$value'),
                ),
              ),
            ),
          ],
          if (formFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            AliceCollapsibleSection(
              icon: Icons.dynamic_form_outlined,
              title: aliceStripColon(
                context.i18n(AliceTranslationKey.callRequestFormDataFields),
              ),
              count: formFields.length,
              child: AliceKeyValueList(
                values: {
                  for (final AliceFormDataField field in formFields)
                    field.name: field.value,
                },
              ),
            ),
          ],
          if (formFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            AliceCollapsibleSection(
              icon: Icons.attach_file,
              title: aliceStripColon(
                context.i18n(AliceTranslationKey.callRequestFormDataFiles),
              ),
              count: formFiles.length,
              child: AliceKeyValueList(
                values: {
                  for (final AliceFormDataFile file in formFiles)
                    file.fileName ?? '-':
                        '${file.contentType}, '
                        '${AliceConversionHelper.formatBytes(file.length)}',
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          AliceCollapsibleSection(
            icon: Icons.list_alt,
            title: aliceStripColon(
              context.i18n(AliceTranslationKey.callRequestHeaders),
            ),
            count: headers.length,
            initiallyExpanded: headers.length <= 8,
            action:
                headers.isEmpty
                    ? null
                    : AliceCopyIconButton(
                      text: headers.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join('\n'),
                    ),
            child: AliceKeyValueList(
              values: headers.map(
                (String key, dynamic value) => MapEntry(key, '$value'),
              ),
              emptyText: context.i18n(
                AliceTranslationKey.callRequestHeadersEmpty,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AliceCollapsibleSection(
            icon: Icons.data_object,
            title: aliceStripColon(
              context.i18n(AliceTranslationKey.callRequestBody),
            ),
            child: AliceCodeBlock(
              text: AliceParser.formatBody(
                context: context,
                body: request?.body,
                contentType: contentType,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card with method, time, size and content type of the request.
class _RequestSummary extends StatelessWidget {
  const _RequestSummary({required this.call, required this.contentType});

  final AliceHttpCall call;
  final String? contentType;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final DateTime? time = call.request?.time;
    return AliceOutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AliceMethodBadge(method: call.method, fontSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: AliceLtrSelectableText(
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
              AliceInfoChip(
                icon: Icons.schedule,
                text:
                    time != null
                        ? AliceConversionHelper.formatDateTime(time)
                        : '-',
                color: muted,
              ),
              AliceInfoChip(
                icon: Icons.upload_outlined,
                text: AliceConversionHelper.formatBytes(
                  call.request?.size ?? 0,
                ),
                color: muted,
              ),
              if (contentType != null)
                AliceInfoChip(
                  icon: Icons.description_outlined,
                  text: contentType!,
                  color: muted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
