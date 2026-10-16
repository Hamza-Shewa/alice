import 'package:netlens/helper/netlens_conversion_helper.dart';
import 'package:netlens/helper/netlens_graphql.dart';
import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/helper/netlens_url_validator.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_form_data_file.dart';
import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_call_badges.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_detail_widgets.dart';
import 'package:netlens/ui/common/netlens_issue_widgets.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_status_info_sheet.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:netlens/ui/common/netlens_url_issue_banner.dart';
import 'package:netlens/ui/common/netlens_watcher_widgets.dart';
import 'package:netlens/utils/netlens_parser.dart';
import 'package:flutter/material.dart';

/// Screen which displays call overview data, for example method, server.
class NetLensCallOverviewScreen extends StatelessWidget {
  final NetLensHttpCall call;

  const NetLensCallOverviewScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final List<NetLensUrlIssue> urlIssues = NetLensUrlValidator.validateCall(
      call,
    );
    final NetLensIssue? issue = NetLensIssueAnalyzer.analyze(call);
    final NetLensGraphQLOperation? graphQL = NetLensGraphQL.detect(call);
    final DateTime? started = call.request?.time;
    final DateTime? finished = call.loading ? null : call.response?.time;
    final String pending = context.i18n(
      NetLensTranslationKey.callOverviewPending,
    );

    return SelectionArea(
      child: ScrollConfiguration(
        behavior: NetLensScrollBehavior(),
        // Lays out a few screens around the visible area ahead of time, so
        // sections are ready before they scroll in.
        child: LayoutBuilder(
          builder:
              (BuildContext context, BoxConstraints constraints) => ListView(
                // `scrollCacheExtent` replaces this from Flutter 3.44, but
                // NetLens still supports Flutter 3.29.
                // ignore: deprecated_member_use
                cacheExtent:
                    constraints.maxHeight.isFinite
                        ? constraints.maxHeight * _cacheViewports
                        : null,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  if (urlIssues.isNotEmpty) ...[
                    NetLensUrlIssueBanner(issues: urlIssues),
                    const SizedBox(height: 16),
                  ],
                  _SummaryCard(call: call, hasUrlIssues: urlIssues.isNotEmpty),
                  if (issue != null) ...[
                    const SizedBox(height: 12),
                    NetLensIssueBanner(issue: issue),
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
                              NetLensTranslationKey.callOverviewDuration,
                            ),
                            value:
                                call.loading
                                    ? pending
                                    : NetLensConversionHelper.formatTime(
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
                              NetLensTranslationKey.callOverviewBytesSent,
                            ),
                            value: NetLensConversionHelper.formatBytes(
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
                              NetLensTranslationKey.callOverviewBytesReceived,
                            ),
                            value: NetLensConversionHelper.formatBytes(
                              call.response?.size ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  NetLensInfoSection(
                    title: context.i18n(
                      NetLensTranslationKey.callOverviewTiming,
                    ),
                    rows: [
                      NetLensInfoRow(
                        label: _label(
                          context,
                          NetLensTranslationKey.callOverviewStarted,
                        ),
                        value:
                            started != null
                                ? NetLensConversionHelper.formatDateTime(
                                  started,
                                )
                                : pending,
                      ),
                      NetLensInfoRow(
                        label: _label(
                          context,
                          NetLensTranslationKey.callOverviewFinished,
                        ),
                        value:
                            finished != null
                                ? NetLensConversionHelper.formatDateTime(
                                  finished,
                                )
                                : pending,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  NetLensInfoSection(
                    title: context.i18n(
                      NetLensTranslationKey.callOverviewConnection,
                    ),
                    rows: [
                      NetLensInfoRow(
                        label: _label(
                          context,
                          NetLensTranslationKey.callOverviewMethod,
                        ),
                        value: call.method,
                      ),
                      NetLensInfoRow(
                        label: _label(
                          context,
                          NetLensTranslationKey.callOverviewServer,
                        ),
                        value: call.server,
                        hasError: urlIssues.isNotEmpty,
                      ),
                      NetLensInfoRow(
                        label: _label(
                          context,
                          NetLensTranslationKey.callOverviewEndpoint,
                        ),
                        value: call.endpoint,
                        hasError: urlIssues.isNotEmpty,
                      ),
                      if (graphQL != null)
                        NetLensInfoRow(
                          label: _label(
                            context,
                            NetLensTranslationKey.callOverviewGraphQL,
                          ),
                          value:
                              graphQL.hasErrors
                                  ? '${graphQL.title} (${context.i18n(NetLensTranslationKey.graphQLErrors)})'
                                  : graphQL.title,
                          hasError: graphQL.hasErrors,
                        ),
                      NetLensInfoRow(
                        label: _label(
                          context,
                          NetLensTranslationKey.callOverviewClient,
                        ),
                        value: call.client.isEmpty ? '-' : call.client,
                      ),
                      NetLensInfoRow(
                        label: _label(
                          context,
                          NetLensTranslationKey.callOverviewSecure,
                        ),
                        value: context.i18n(
                          call.secure
                              ? NetLensTranslationKey.callsListYes
                              : NetLensTranslationKey.callsListNo,
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
                    NetLensDetailSection(
                      title: context.i18n(
                        NetLensTranslationKey.callDetailsError,
                      ),
                      children: [
                        NetLensCodeBlock(
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
  static String _label(BuildContext context, NetLensTranslationKey key) =>
      netLensStripColon(context.i18n(key));
}

/// Section with request query parameters, form data, headers and body.
class _RequestSection extends StatelessWidget {
  const _RequestSection({required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    final NetLensHttpRequest? request = call.request;
    final List<NetLensFormDataField> formFields = request?.formDataFields ?? [];
    final List<NetLensFormDataFile> formFiles = request?.formDataFiles ?? [];
    final String? rawContentType = request?.contentType;
    final String? contentType =
        (rawContentType != null && rawContentType.trim().isNotEmpty)
            ? rawContentType
            : NetLensParser.tryGetContentType(request?.headers);

    return NetLensDetailSection(
      title: context.i18n(NetLensTranslationKey.callDetailsRequest),
      children: [
        if (request?.queryParameters.isNotEmpty ?? false)
          NetLensGroup(
            title: netLensStripColon(
              context.i18n(NetLensTranslationKey.callRequestQueryParameters),
            ),
            child: NetLensKeyValueList(
              values: request!.queryParameters.map(
                (key, value) => MapEntry(key, '$value'),
              ),
            ),
          ),
        if (formFields.isNotEmpty)
          NetLensGroup(
            title: netLensStripColon(
              context.i18n(NetLensTranslationKey.callRequestFormDataFields),
            ),
            child: NetLensKeyValueList(
              values: {
                for (final NetLensFormDataField field in formFields)
                  field.name: field.value,
              },
            ),
          ),
        if (formFiles.isNotEmpty)
          NetLensGroup(
            title: netLensStripColon(
              context.i18n(NetLensTranslationKey.callRequestFormDataFiles),
            ),
            child: NetLensKeyValueList(
              values: {
                for (final NetLensFormDataFile file in formFiles)
                  file.fileName ?? '-':
                      '${file.contentType}, '
                      '${NetLensConversionHelper.formatBytes(file.length)}',
              },
            ),
          ),
        NetLensGroup(
          title: netLensStripColon(
            context.i18n(NetLensTranslationKey.callRequestHeaders),
          ),
          child: NetLensKeyValueList(
            values: request?.headers,
            emptyText: context.i18n(
              NetLensTranslationKey.callRequestHeadersEmpty,
            ),
          ),
        ),
        NetLensGroup(
          title: netLensStripColon(
            context.i18n(NetLensTranslationKey.callRequestBody),
          ),
          child: NetLensFormattedBodyBlock(
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

  final NetLensHttpCall call;

  @override
  State<_ResponseSection> createState() => _ResponseSectionState();
}

class _ResponseSectionState extends State<_ResponseSection> {
  static const int _largeOutputSize = 100000;
  bool _showLargeBody = false;

  @override
  Widget build(BuildContext context) {
    final NetLensHttpCall call = widget.call;
    final NetLensHttpResponse? response = call.response;
    if (call.loading) {
      return NetLensDetailSection(
        title: context.i18n(NetLensTranslationKey.callDetailsResponse),
        children: [
          Text(
            context.i18n(NetLensTranslationKey.callResponseWaitingForResponse),
          ),
        ],
      );
    }
    final String? contentType = NetLensParser.getContentType(
      context: context,
      headers: response?.headers,
    );
    final String lowerContentType = contentType?.toLowerCase() ?? '';
    final int bodyLength = response?.body?.toString().length ?? 0;
    final bool isLargeBody = bodyLength > _largeOutputSize;

    return NetLensDetailSection(
      title: context.i18n(NetLensTranslationKey.callDetailsResponse),
      children: [
        NetLensGroup(
          title: netLensStripColon(
            context.i18n(NetLensTranslationKey.callResponseHeaders),
          ),
          child: NetLensKeyValueList(
            values: response?.headers,
            emptyText: context.i18n(
              NetLensTranslationKey.callResponseHeadersEmpty,
            ),
          ),
        ),
        NetLensGroup(
          title: netLensStripColon(
            context.i18n(NetLensTranslationKey.callResponseBody),
          ),
          child:
              lowerContentType.contains('image')
                  ? Text(
                    context.i18n(NetLensTranslationKey.callResponseBodyImage),
                  )
                  : lowerContentType.contains('video')
                  ? Text(
                    context.i18n(NetLensTranslationKey.callResponseBodyVideo),
                  )
                  : (isLargeBody && !_showLargeBody)
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NetLensInfoChip(
                        icon: Icons.scale_outlined,
                        text:
                            '${context.i18n(NetLensTranslationKey.callResponseTooLargeToShow)}'
                            ' (${NetLensConversionHelper.formatBytes(bodyLength)})',
                        color: NetLensTheme.getStatusColor(context, 300),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () => setState(() => _showLargeBody = true),
                        icon: const Icon(Icons.article_outlined, size: 18),
                        label: Text(
                          context.i18n(
                            NetLensTranslationKey.callResponseBodyShow,
                          ),
                        ),
                      ),
                    ],
                  )
                  : NetLensFormattedBodyBlock(
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
String _getUrl(NetLensHttpCall call) {
  if (call.uri.isNotEmpty) {
    return call.uri;
  }
  return '${call.secure ? 'https' : 'http'}://${call.server}${call.endpoint}';
}

/// Card with method, status, full URL and connection chips.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.call, required this.hasUrlIssues});

  final NetLensHttpCall call;
  final bool hasUrlIssues;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color urlIssueColor = getUrlIssueColor(context);
    final String url = _getUrl(call);
    final NetLensWatchResult? watch = NetLensWatcher.instance.evaluate(call);

    return NetLensOutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetLensMethodBadge(method: call.method, fontSize: 14),
              const Spacer(),
              if (watch != null) ...[
                Flexible(child: NetLensWatchChip(result: watch)),
                const SizedBox(width: 8),
              ],
              if (call.loading)
                NetLensStatusPill(call: call, fontSize: 15)
              else
                Tooltip(
                  message: context.i18n(NetLensTranslationKey.statusTapHint),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap:
                        () => showNetLensStatusInfo(
                          context: context,
                          status: call.response?.status,
                        ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NetLensStatusPill(call: call, fontSize: 15),
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
            NetLensWatchResultBox(result: watch),
          ],
          const SizedBox(height: 14),
          NetLensLtrText(
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
              NetLensInfoChip(
                icon: call.secure ? Icons.lock_outline : Icons.lock_open,
                text: call.secure ? 'HTTPS' : 'HTTP',
                color: NetLensTheme.getStatusColor(
                  context,
                  call.secure ? 200 : 400,
                ),
              ),
              if (call.client.isNotEmpty)
                NetLensInfoChip(
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
      label: Text(context.i18n(NetLensTranslationKey.callOverviewCopyUrl)),
      onPressed:
          () => netLensCopyToClipboard(
            context,
            url,
            context.i18n(NetLensTranslationKey.callOverviewCopied),
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
    return NetLensOutlinedCard(
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
