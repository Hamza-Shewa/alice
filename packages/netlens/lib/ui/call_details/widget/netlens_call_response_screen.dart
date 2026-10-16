import 'package:netlens/core/netlens_http_status.dart';
import 'package:netlens/helper/netlens_conversion_helper.dart';
import 'package:netlens/helper/netlens_issue_analyzer.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_call_badges.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_detail_widgets.dart';
import 'package:netlens/ui/common/netlens_issue_widgets.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_status_info_sheet.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:netlens/ui/common/netlens_watcher_widgets.dart';
import 'package:netlens/utils/netlens_parser.dart';
import 'package:netlens/utils/num_comparison.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen which displays information about HTTP call response: status,
/// headers and body.
class NetLensCallResponseScreen extends StatelessWidget {
  const NetLensCallResponseScreen({super.key, required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    if (call.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              context.i18n(
                NetLensTranslationKey.callResponseWaitingForResponse,
              ),
            ),
          ],
        ),
      );
    }

    final NetLensIssue? issue = NetLensIssueAnalyzer.analyze(call);
    final Map<String, String> headers = call.response?.headers ?? const {};
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
            _StatusSummary(call: call),
            const SizedBox(height: 12),
            NetLensCollapsibleSection(
              icon: Icons.list_alt,
              title: netLensStripColon(
                context.i18n(NetLensTranslationKey.callResponseHeaders),
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
                values: headers,
                emptyText: context.i18n(
                  NetLensTranslationKey.callResponseHeadersEmpty,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BodyDataColumn(call: call),
          ],
        ),
      ),
    );
  }
}

/// Card with status code, its name, received time, size and content type.
class _StatusSummary extends StatelessWidget {
  const _StatusSummary({required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final int? status = call.response?.status;
    final Color color = NetLensTheme.getStatusColor(context, status);
    final NetLensHttpStatusInfo? info = NetLensHttpStatus.get(
      status: status,
      languageCode: NetLensLanguage.current.value,
    );
    final String name =
        status == -1
            ? context.i18n(NetLensTranslationKey.callResponseError)
            : info?.name ?? context.i18n(NetLensTranslationKey.unknown);
    final String? contentType = NetLensParser.getContentType(
      context: context,
      headers: call.response?.headers,
    );
    final NetLensWatchResult? watch = NetLensWatcher.instance.evaluate(call);

    return NetLensOutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap:
                () => showNetLensStatusInfo(context: context, status: status),
            child: Row(
              children: [
                Text(
                  NetLensStatusPill.getStatusText(status),
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.info_outline, size: 20, color: muted),
              ],
            ),
          ),
          if (watch != null) ...[
            const SizedBox(height: 12),
            NetLensWatchResultBox(result: watch),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NetLensInfoChip(
                icon: Icons.schedule,
                text:
                    call.response != null
                        ? NetLensConversionHelper.formatDateTime(
                          call.response!.time,
                        )
                        : '-',
                color: muted,
              ),
              NetLensInfoChip(
                icon: Icons.download_outlined,
                text: NetLensConversionHelper.formatBytes(
                  call.response?.size ?? 0,
                ),
                color: muted,
              ),
              NetLensInfoChip(
                icon: Icons.timer_outlined,
                text: NetLensConversionHelper.formatTime(call.duration),
                color: muted,
              ),
              if (contentType != null)
                NetLensInfoChip(
                  icon: Icons.description_outlined,
                  text: contentType,
                  color: muted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget which renders the body of [call] in a way which matches its type.
class _BodyDataColumn extends StatefulWidget {
  const _BodyDataColumn({required this.call});

  final NetLensHttpCall call;

  @override
  State<_BodyDataColumn> createState() => _BodyDataColumnState();
}

class _BodyDataColumnState extends State<_BodyDataColumn> {
  static const String _imageContentType = 'image';
  static const String _videoContentType = 'video';
  static const String _jsonContentType = 'json';
  static const String _xmlContentType = 'xml';
  static const String _textContentType = 'text';

  static const int _largeOutputSize = 100000;
  bool _showLargeBody = false;
  bool _showUnsupportedBody = false;

  NetLensHttpCall get call => widget.call;

  @override
  Widget build(BuildContext context) {
    if (_isImageResponse()) {
      return _ImageBody(call: call);
    } else if (_isVideoResponse()) {
      return _VideoBody(call: call);
    } else if (_isTextResponse()) {
      if (_isLargeResponseBody() && !_showLargeBody) {
        return _LargeTextBody(
          call: call,
          onShowLargeBodyPressed: () => setState(() => _showLargeBody = true),
        );
      }
      return _TextBody(call: call);
    } else {
      return _UnknownBody(
        call: call,
        showUnsupportedBody: _showUnsupportedBody,
        onShowUnsupportedBodyPressed:
            () => setState(() => _showUnsupportedBody = true),
      );
    }
  }

  /// Checks whether content type of response is image.
  bool _isImageResponse() =>
      _getContentTypeOfResponse()!.toLowerCase().contains(_imageContentType);

  /// Checks whether content type of response is video
  bool _isVideoResponse() =>
      _getContentTypeOfResponse()!.toLowerCase().contains(_videoContentType);

  /// Checks whether content type of response is text.
  bool _isTextResponse() {
    final String contentType = _getContentTypeOfResponse()!.toLowerCase();
    return contentType.contains(_jsonContentType) ||
        contentType.contains(_xmlContentType) ||
        contentType.contains(_textContentType);
  }

  /// Parses headers and returns content type of response. It may return null.
  String? _getContentTypeOfResponse() {
    return NetLensParser.getContentType(
      context: context,
      headers: call.response?.headers,
    );
  }

  /// Checks whether response body is large (more than [_largeOutputSize].
  bool _isLargeResponseBody() =>
      call.response?.body.toString().length.gt(_largeOutputSize) ?? false;
}

/// Section title of the response body.
String _bodyTitle(BuildContext context) =>
    netLensStripColon(context.i18n(NetLensTranslationKey.callResponseBody));

/// Widget which renders body as image.
class _ImageBody extends StatelessWidget {
  const _ImageBody({required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    return NetLensCollapsibleSection(
      icon: Icons.image_outlined,
      title: context.i18n(NetLensTranslationKey.callResponseBodyImage),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          call.uri,
          fit: BoxFit.contain,
          width: double.infinity,
          headers: _buildRequestHeaders(),
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) =>
                  NetLensCodeBlock(text: '$error', isError: true),
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) return child;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds request headers to access the image.
  Map<String, String> _buildRequestHeaders() {
    final requestHeaders = <String, String>{};
    if (call.request?.headers != null) {
      requestHeaders.addAll(
        call.request!.headers.map(
          (String key, dynamic value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return requestHeaders;
  }
}

/// Widget which asks before rendering a large body as a text.
class _LargeTextBody extends StatelessWidget {
  const _LargeTextBody({
    required this.call,
    required this.onShowLargeBodyPressed,
  });

  final NetLensHttpCall call;
  final void Function() onShowLargeBodyPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color warningColor = NetLensTheme.getStatusColor(context, 300);
    return NetLensCollapsibleSection(
      icon: Icons.data_object,
      title: _bodyTitle(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetLensInfoChip(
            icon: Icons.scale_outlined,
            text:
                '${context.i18n(NetLensTranslationKey.callResponseTooLargeToShow)}'
                ' (${call.response?.body.toString().length ?? 0} B)',
            color: warningColor,
          ),
          const SizedBox(height: 10),
          Text(
            context.i18n(
              NetLensTranslationKey.callResponseLargeBodyShowWarning,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onShowLargeBodyPressed,
            icon: const Icon(Icons.article_outlined, size: 18),
            label: Text(
              context.i18n(NetLensTranslationKey.callResponseBodyShow),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget which renders body as a text.
class _TextBody extends StatelessWidget {
  const _TextBody({required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    return NetLensCollapsibleSection(
      icon: Icons.data_object,
      title: _bodyTitle(context),
      child: NetLensFormattedBodyBlock(
        body: call.response?.body,
        contentType: NetLensParser.getContentType(
          context: context,
          headers: call.response?.headers,
        ),
      ),
    );
  }
}

/// Widget which renders body as video.
class _VideoBody extends StatelessWidget {
  const _VideoBody({required this.call});

  final NetLensHttpCall call;

  @override
  Widget build(BuildContext context) {
    return NetLensCollapsibleSection(
      icon: Icons.videocam_outlined,
      title: context.i18n(NetLensTranslationKey.callResponseBodyVideo),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilledButton.tonalIcon(
          icon: const Icon(Icons.open_in_new, size: 18),
          label: Text(
            context.i18n(NetLensTranslationKey.callResponseBodyVideoWebBrowser),
          ),
          onPressed: () async {
            await launchUrl(Uri.parse(call.uri));
          },
        ),
      ),
    );
  }
}

/// Widget which renders unsupported body: explains why the body can't be
/// previewed and allows to show it as raw text.
class _UnknownBody extends StatelessWidget {
  static const _contentType = "[contentType]";

  const _UnknownBody({
    required this.call,
    required this.showUnsupportedBody,
    required this.onShowUnsupportedBodyPressed,
  });

  final NetLensHttpCall call;
  final bool showUnsupportedBody;
  final void Function() onShowUnsupportedBodyPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, String>? headers = call.response?.headers;
    final String contentType =
        NetLensParser.getContentType(context: context, headers: headers) ??
        context.i18n(NetLensTranslationKey.callResponseHeadersUnknown);
    final Color warningColor = NetLensTheme.getStatusColor(context, 300);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: NetLensOutlinedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility_off_outlined, color: warningColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.i18n(
                      NetLensTranslationKey.callResponseBodyUnsupportedTitle,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                _BodyInfoChip(
                  icon: Icons.description_outlined,
                  text: contentType,
                  color: warningColor,
                ),
                _BodyInfoChip(
                  icon: Icons.download_outlined,
                  text: NetLensConversionHelper.formatBytes(
                    call.response?.size ?? 0,
                  ),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context
                  .i18n(
                    NetLensTranslationKey
                        .callResponseBodyUnsupportedDescription,
                  )
                  .replaceAll(_contentType, contentType),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 16),
            if (showUnsupportedBody)
              NetLensFormattedBodyBlock(
                body: call.response?.body,
                contentType: contentType,
              )
            else ...[
              Text(
                context.i18n(
                  NetLensTranslationKey.callResponseBodyUnsupportedWarning,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onShowUnsupportedBodyPressed,
                icon: const Icon(Icons.article_outlined, size: 18),
                label: Text(
                  context.i18n(
                    NetLensTranslationKey.callResponseBodyUnknownShow,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small rounded label with an icon.
class _BodyInfoChip extends StatelessWidget {
  const _BodyInfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
