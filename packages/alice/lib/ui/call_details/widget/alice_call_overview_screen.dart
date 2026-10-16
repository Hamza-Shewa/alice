import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_graphql.dart';
import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:alice/ui/common/alice_issue_widgets.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/ui/common/alice_status_info_sheet.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/common/alice_url_issue_banner.dart';
import 'package:alice/ui/common/alice_watcher_widgets.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:flutter/material.dart';

/// Screen which displays call overview data, for example method, server.
class AliceCallOverviewScreen extends StatelessWidget {
  final AliceHttpCall call;

  const AliceCallOverviewScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final List<AliceUrlIssue> urlIssues = AliceUrlValidator.validateCall(call);
    final AliceIssue? issue = AliceIssueAnalyzer.analyze(call);
    final AliceGraphQLOperation? graphQL = AliceGraphQL.detect(call);
    final DateTime? started = call.request?.time;
    final DateTime? finished = call.loading ? null : call.response?.time;
    final String pending = context.i18n(
      AliceTranslationKey.callOverviewPending,
    );

    return SelectionArea(
      child: ScrollConfiguration(
        behavior: AliceScrollBehavior(),
        // Lays out a few screens around the visible area ahead of time, so
        // sections are ready before they scroll in.
        child: LayoutBuilder(
          builder:
              (BuildContext context, BoxConstraints constraints) => ListView(
                // `scrollCacheExtent` replaces this from Flutter 3.44, but
                // Alice still supports Flutter 3.29.
                // ignore: deprecated_member_use
                cacheExtent:
                    constraints.maxHeight.isFinite
                        ? constraints.maxHeight * _cacheViewports
                        : null,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  if (urlIssues.isNotEmpty) ...[
                    AliceUrlIssueBanner(issues: urlIssues),
                    const SizedBox(height: 16),
                  ],
                  _SummaryCard(call: call, hasUrlIssues: urlIssues.isNotEmpty),
                  if (issue != null) ...[
                    const SizedBox(height: 12),
                    AliceIssueBanner(issue: issue),
                  ],
                  const SizedBox(height: 12),
                  // Stretch makes all tiles as tall as the tallest one.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.timer_outlined,
                            label: _label(
                              context,
                              AliceTranslationKey.callOverviewDuration,
                            ),
                            value:
                                call.loading
                                    ? pending
                                    : AliceConversionHelper.formatTime(
                                      call.duration,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.upload_outlined,
                            label: _label(
                              context,
                              AliceTranslationKey.callOverviewBytesSent,
                            ),
                            value: AliceConversionHelper.formatBytes(
                              call.request?.size ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.download_outlined,
                            label: _label(
                              context,
                              AliceTranslationKey.callOverviewBytesReceived,
                            ),
                            value: AliceConversionHelper.formatBytes(
                              call.response?.size ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AliceInfoSection(
                    title: context.i18n(AliceTranslationKey.callOverviewTiming),
                    rows: [
                      AliceInfoRow(
                        label: _label(
                          context,
                          AliceTranslationKey.callOverviewStarted,
                        ),
                        value:
                            started != null
                                ? AliceConversionHelper.formatDateTime(started)
                                : pending,
                      ),
                      AliceInfoRow(
                        label: _label(
                          context,
                          AliceTranslationKey.callOverviewFinished,
                        ),
                        value:
                            finished != null
                                ? AliceConversionHelper.formatDateTime(finished)
                                : pending,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AliceInfoSection(
                    title: context.i18n(
                      AliceTranslationKey.callOverviewConnection,
                    ),
                    rows: [
                      AliceInfoRow(
                        label: _label(
                          context,
                          AliceTranslationKey.callOverviewMethod,
                        ),
                        value: call.method,
                      ),
                      AliceInfoRow(
                        label: _label(
                          context,
                          AliceTranslationKey.callOverviewServer,
                        ),
                        value: call.server,
                        hasError: urlIssues.isNotEmpty,
                      ),
                      AliceInfoRow(
                        label: _label(
                          context,
                          AliceTranslationKey.callOverviewEndpoint,
                        ),
                        value: call.endpoint,
                        hasError: urlIssues.isNotEmpty,
                      ),
                      if (graphQL != null)
                        AliceInfoRow(
                          label: _label(
                            context,
                            AliceTranslationKey.callOverviewGraphQL,
                          ),
                          value:
                              graphQL.hasErrors
                                  ? '${graphQL.title} (${context.i18n(AliceTranslationKey.graphQLErrors)})'
                                  : graphQL.title,
                          hasError: graphQL.hasErrors,
                        ),
                      AliceInfoRow(
                        label: _label(
                          context,
                          AliceTranslationKey.callOverviewClient,
                        ),
                        value: call.client.isEmpty ? '-' : call.client,
                      ),
                      AliceInfoRow(
                        label: _label(
                          context,
                          AliceTranslationKey.callOverviewSecure,
                        ),
                        value: context.i18n(
                          call.secure
                              ? AliceTranslationKey.callsListYes
                              : AliceTranslationKey.callsListNo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _RequestSection(call: call),
                  const SizedBox(height: 20),
                  _ResponseSection(call: call),
                  if (call.error != null) ...[
                    const SizedBox(height: 20),
                    AliceDetailSection(
                      title: context.i18n(AliceTranslationKey.callDetailsError),
                      children: [
                        AliceCodeBlock(
                          text: [
                            '${call.error?.error}',
                            if (call.error?.stackTrace != null)
                              '${call.error?.stackTrace}',
                          ].join('\n\n'),
                          isError: true,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
        ),
      ),
    );
  }

  /// Number of viewport heights laid out around the visible area.
  static const double _cacheViewports = 5;

  /// Returns translated label without trailing colon.
  static String _label(BuildContext context, AliceTranslationKey key) =>
      aliceStripColon(context.i18n(key));
}

/// Section with request query parameters, form data, headers and body.
class _RequestSection extends StatelessWidget {
  const _RequestSection({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final AliceHttpRequest? request = call.request;
    final List<AliceFormDataField> formFields = request?.formDataFields ?? [];
    final List<AliceFormDataFile> formFiles = request?.formDataFiles ?? [];
    final String? rawContentType = request?.contentType;
    final String? contentType =
        (rawContentType != null && rawContentType.trim().isNotEmpty)
            ? rawContentType
            : AliceParser.tryGetContentType(request?.headers);

    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.callDetailsRequest),
      children: [
        if (request?.queryParameters.isNotEmpty ?? false)
          AliceGroup(
            title: aliceStripColon(
              context.i18n(AliceTranslationKey.callRequestQueryParameters),
            ),
            child: AliceKeyValueList(
              values: request!.queryParameters.map(
                (key, value) => MapEntry(key, '$value'),
              ),
            ),
          ),
        if (formFields.isNotEmpty)
          AliceGroup(
            title: aliceStripColon(
              context.i18n(AliceTranslationKey.callRequestFormDataFields),
            ),
            child: AliceKeyValueList(
              values: {
                for (final AliceFormDataField field in formFields)
                  field.name: field.value,
              },
            ),
          ),
        if (formFiles.isNotEmpty)
          AliceGroup(
            title: aliceStripColon(
              context.i18n(AliceTranslationKey.callRequestFormDataFiles),
            ),
            child: AliceKeyValueList(
              values: {
                for (final AliceFormDataFile file in formFiles)
                  file.fileName ?? '-':
                      '${file.contentType}, '
                      '${AliceConversionHelper.formatBytes(file.length)}',
              },
            ),
          ),
        AliceGroup(
          title: aliceStripColon(
            context.i18n(AliceTranslationKey.callRequestHeaders),
          ),
          child: AliceKeyValueList(
            values: request?.headers,
            emptyText: context.i18n(
              AliceTranslationKey.callRequestHeadersEmpty,
            ),
          ),
        ),
        AliceGroup(
          title: aliceStripColon(
            context.i18n(AliceTranslationKey.callRequestBody),
          ),
          child: AliceFormattedBodyBlock(
            body: request?.body,
            contentType: contentType,
          ),
        ),
      ],
    );
  }
}

/// Section with response headers and body.
class _ResponseSection extends StatefulWidget {
  const _ResponseSection({required this.call});

  final AliceHttpCall call;

  @override
  State<_ResponseSection> createState() => _ResponseSectionState();
}

class _ResponseSectionState extends State<_ResponseSection> {
  static const int _largeOutputSize = 100000;
  bool _showLargeBody = false;

  @override
  Widget build(BuildContext context) {
    final AliceHttpCall call = widget.call;
    final AliceHttpResponse? response = call.response;
    if (call.loading) {
      return AliceDetailSection(
        title: context.i18n(AliceTranslationKey.callDetailsResponse),
        children: [
          Text(
            context.i18n(AliceTranslationKey.callResponseWaitingForResponse),
          ),
        ],
      );
    }
    final String? contentType = AliceParser.getContentType(
      context: context,
      headers: response?.headers,
    );
    final String lowerContentType = contentType?.toLowerCase() ?? '';
    final int bodyLength = response?.body?.toString().length ?? 0;
    final bool isLargeBody = bodyLength > _largeOutputSize;

    return AliceDetailSection(
      title: context.i18n(AliceTranslationKey.callDetailsResponse),
      children: [
        AliceGroup(
          title: aliceStripColon(
            context.i18n(AliceTranslationKey.callResponseHeaders),
          ),
          child: AliceKeyValueList(
            values: response?.headers,
            emptyText: context.i18n(
              AliceTranslationKey.callResponseHeadersEmpty,
            ),
          ),
        ),
        AliceGroup(
          title: aliceStripColon(
            context.i18n(AliceTranslationKey.callResponseBody),
          ),
          child:
              lowerContentType.contains('image')
                  ? Text(
                    context.i18n(AliceTranslationKey.callResponseBodyImage),
                  )
                  : lowerContentType.contains('video')
                  ? Text(
                    context.i18n(AliceTranslationKey.callResponseBodyVideo),
                  )
                  : (isLargeBody && !_showLargeBody)
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AliceInfoChip(
                        icon: Icons.scale_outlined,
                        text:
                            '${context.i18n(AliceTranslationKey.callResponseTooLargeToShow)}'
                            ' (${AliceConversionHelper.formatBytes(bodyLength)})',
                        color: AliceTheme.getStatusColor(context, 300),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () => setState(() => _showLargeBody = true),
                        icon: const Icon(Icons.article_outlined, size: 18),
                        label: Text(
                          context.i18n(
                            AliceTranslationKey.callResponseBodyShow,
                          ),
                        ),
                      ),
                    ],
                  )
                  : AliceFormattedBodyBlock(
                    body: response?.body,
                    contentType: contentType,
                  ),
        ),
      ],
    );
  }
}

/// Returns full URL of [call], built from server and endpoint when URI is
/// missing.
String _getUrl(AliceHttpCall call) {
  if (call.uri.isNotEmpty) {
    return call.uri;
  }
  return '${call.secure ? 'https' : 'http'}://${call.server}${call.endpoint}';
}

/// Card with method, status, full URL and connection chips.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.call, required this.hasUrlIssues});

  final AliceHttpCall call;
  final bool hasUrlIssues;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color urlIssueColor = getUrlIssueColor(context);
    final String url = _getUrl(call);
    final AliceWatchResult? watch = AliceWatcher.instance.evaluate(call);

    return AliceOutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AliceMethodBadge(method: call.method, fontSize: 14),
              const Spacer(),
              if (watch != null) ...[
                Flexible(child: AliceWatchChip(result: watch)),
                const SizedBox(width: 8),
              ],
              if (call.loading)
                AliceStatusPill(call: call, fontSize: 15)
              else
                Tooltip(
                  message: context.i18n(AliceTranslationKey.statusTapHint),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap:
                        () => showAliceStatusInfo(
                          context: context,
                          status: call.response?.status,
                        ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AliceStatusPill(call: call, fontSize: 15),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (watch != null && watch.meaning.isNotEmpty) ...[
            const SizedBox(height: 12),
            AliceWatchResultBox(result: watch),
          ],
          const SizedBox(height: 14),
          AliceLtrText(
            url,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: hasUrlIssues ? urlIssueColor : theme.colorScheme.onSurface,
              decoration: hasUrlIssues ? TextDecoration.underline : null,
              decorationStyle: TextDecorationStyle.wavy,
              decorationColor: urlIssueColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AliceInfoChip(
                icon: call.secure ? Icons.lock_outline : Icons.lock_open,
                text: call.secure ? 'HTTPS' : 'HTTP',
                color: AliceTheme.getStatusColor(
                  context,
                  call.secure ? 200 : 400,
                ),
              ),
              if (call.client.isNotEmpty)
                AliceInfoChip(
                  icon: Icons.settings_ethernet,
                  text: call.client,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              _CopyButton(url: url),
            ],
          ),
        ],
      ),
    );
  }
}

/// Button which copies call URL to clipboard.
class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: const Icon(Icons.copy, size: 16),
      label: Text(context.i18n(AliceTranslationKey.callOverviewCopyUrl)),
      onPressed:
          () => aliceCopyToClipboard(
            context,
            url,
            context.i18n(AliceTranslationKey.callOverviewCopied),
          ),
    );
  }
}

/// Tile which displays one key number, for example duration.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color mutedColor = theme.colorScheme.onSurfaceVariant;
    return AliceOutlinedCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: mutedColor),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            // Values like "342 ms" must not be reordered in RTL layouts.
            textDirection: TextDirection.ltr,
            textAlign:
                Directionality.of(context) == TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.left,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
        ],
      ),
    );
  }
}
