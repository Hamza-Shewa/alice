import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_call_badges.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/ui/common/alice_status_info_sheet.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/common/alice_url_issue_banner.dart';
import 'package:alice/utils/alice_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen which displays call overview data, for example method, server.
class AliceCallOverviewScreen extends StatelessWidget {
  final AliceHttpCall call;

  const AliceCallOverviewScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final List<AliceUrlIssue> urlIssues = AliceUrlValidator.validateCall(call);
    final DateTime? started = call.request?.time;
    final DateTime? finished = call.loading ? null : call.response?.time;
    final String pending = context.i18n(
      AliceTranslationKey.callOverviewPending,
    );

    return ScrollConfiguration(
      behavior: AliceScrollBehavior(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (urlIssues.isNotEmpty) ...[
            AliceUrlIssueBanner(issues: urlIssues),
            const SizedBox(height: 16),
          ],
          _SummaryCard(call: call, hasUrlIssues: urlIssues.isNotEmpty),
          const SizedBox(height: 12),
          Row(
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
                          : AliceConversionHelper.formatTime(call.duration),
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
          const SizedBox(height: 20),
          _Section(
            title: context.i18n(AliceTranslationKey.callOverviewTiming),
            rows: [
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewStarted),
                value:
                    started != null
                        ? AliceConversionHelper.formatDateTime(started)
                        : pending,
              ),
              _InfoRow(
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
          _Section(
            title: context.i18n(AliceTranslationKey.callOverviewConnection),
            rows: [
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewMethod),
                value: call.method,
              ),
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewServer),
                value: call.server,
                hasError: urlIssues.isNotEmpty,
              ),
              _InfoRow(
                label: _label(
                  context,
                  AliceTranslationKey.callOverviewEndpoint,
                ),
                value: call.endpoint,
                hasError: urlIssues.isNotEmpty,
              ),
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewClient),
                value: call.client.isEmpty ? '-' : call.client,
              ),
              _InfoRow(
                label: _label(context, AliceTranslationKey.callOverviewSecure),
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
            _DetailSection(
              title: context.i18n(AliceTranslationKey.callDetailsError),
              children: [
                _CodeBlock(
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
    );
  }

  /// Returns translated label without trailing colon.
  static String _label(BuildContext context, AliceTranslationKey key) =>
      _stripColon(context.i18n(key));
}

/// Returns [text] without trailing colon.
String _stripColon(String text) => text.replaceFirst(RegExp(r':\s*$'), '');

/// Section with request query parameters, form data, headers and body.
class _RequestSection extends StatelessWidget {
  const _RequestSection({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final AliceHttpRequest? request = call.request;
    final List<AliceFormDataField> formFields = request?.formDataFields ?? [];
    final List<AliceFormDataFile> formFiles = request?.formDataFiles ?? [];
    return _DetailSection(
      title: context.i18n(AliceTranslationKey.callDetailsRequest),
      children: [
        if (request?.queryParameters.isNotEmpty ?? false)
          _Group(
            title: _stripColon(
              context.i18n(AliceTranslationKey.callRequestQueryParameters),
            ),
            child: _KeyValueList(
              values: request!.queryParameters.map(
                (key, value) => MapEntry(key, '$value'),
              ),
            ),
          ),
        if (formFields.isNotEmpty)
          _Group(
            title: _stripColon(
              context.i18n(AliceTranslationKey.callRequestFormDataFields),
            ),
            child: _KeyValueList(
              values: {
                for (final AliceFormDataField field in formFields)
                  field.name: field.value,
              },
            ),
          ),
        if (formFiles.isNotEmpty)
          _Group(
            title: _stripColon(
              context.i18n(AliceTranslationKey.callRequestFormDataFiles),
            ),
            child: _KeyValueList(
              values: {
                for (final AliceFormDataFile file in formFiles)
                  file.fileName ?? '-':
                      '${file.contentType}, '
                      '${AliceConversionHelper.formatBytes(file.length)}',
              },
            ),
          ),
        _Group(
          title: _stripColon(
            context.i18n(AliceTranslationKey.callRequestHeaders),
          ),
          child: _KeyValueList(
            values: request?.headers,
            emptyText: context.i18n(
              AliceTranslationKey.callRequestHeadersEmpty,
            ),
          ),
        ),
        _Group(
          title: _stripColon(context.i18n(AliceTranslationKey.callRequestBody)),
          child: _CodeBlock(
            text: AliceParser.formatBody(
              context: context,
              body: request?.body,
              contentType: request?.contentType,
            ),
          ),
        ),
      ],
    );
  }
}

/// Section with response headers and body.
class _ResponseSection extends StatelessWidget {
  const _ResponseSection({required this.call});

  final AliceHttpCall call;

  @override
  Widget build(BuildContext context) {
    final AliceHttpResponse? response = call.response;
    if (call.loading) {
      return _DetailSection(
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
    return _DetailSection(
      title: context.i18n(AliceTranslationKey.callDetailsResponse),
      children: [
        _Group(
          title: _stripColon(
            context.i18n(AliceTranslationKey.callResponseHeaders),
          ),
          child: _KeyValueList(
            values: response?.headers,
            emptyText: context.i18n(
              AliceTranslationKey.callResponseHeadersEmpty,
            ),
          ),
        ),
        _Group(
          title: _stripColon(
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
                  : _CodeBlock(
                    text: AliceParser.formatBody(
                      context: context,
                      body: response?.body,
                      contentType: contentType,
                    ),
                  ),
        ),
      ],
    );
  }
}

/// Titled card with free-form content, used for request and response data.
class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        _OutlinedCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 16),
                children[index],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Upper-case title displayed above a section card.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Small heading with content below it.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// List of key/value pairs such as headers. Keys are shown above values so
/// long header names and values stay readable.
class _KeyValueList extends StatelessWidget {
  const _KeyValueList({required this.values, this.emptyText = '-'});

  final Map<String, String>? values;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, String> entries = values ?? const {};
    if (entries.isEmpty) {
      return Text(
        emptyText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final Color dividerColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.08,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final MapEntry<String, String> entry in entries.entries)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: dividerColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LtrSelectableText(
                  entry.key,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                _LtrSelectableText(
                  entry.value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Monospace block for bodies and errors, with copy and show more actions.
class _CodeBlock extends StatefulWidget {
  const _CodeBlock({required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  static const int _collapsedLines = 15;
  static const int _collapsedChars = 1500;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> lines = widget.text.split('\n');
    final bool isLong =
        lines.length > _collapsedLines || widget.text.length > _collapsedChars;
    String shownText = widget.text;
    if (isLong && !_expanded) {
      shownText = lines.take(_collapsedLines).join('\n');
      if (shownText.length > _collapsedChars) {
        shownText = shownText.substring(0, _collapsedChars);
      }
      shownText += '\n…';
    }
    final Color errorColor = getUrlIssueColor(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            widget.isError
                ? Border.all(color: errorColor.withValues(alpha: 0.5))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 44, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: SelectableText(
                    shownText,
                    // Code is always read left to right, also in RTL layouts.
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontFamilyFallback: const ['Courier', 'Menlo'],
                      fontSize: 12.5,
                      height: 1.45,
                      color:
                          widget.isError
                              ? errorColor
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 2,
                end: 2,
                child: _CopyIconButton(text: widget.text),
              ),
            ],
          ),
          if (isLong)
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                context.i18n(
                  _expanded
                      ? AliceTranslationKey.callOverviewShowLess
                      : AliceTranslationKey.callOverviewShowMore,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icon button which copies [text] to clipboard and confirms with snack bar.
class _CopyIconButton extends StatelessWidget {
  const _CopyIconButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy, size: 18),
      visualDensity: VisualDensity.compact,
      tooltip: context.i18n(AliceTranslationKey.callOverviewCopy),
      onPressed:
          () => _copyToClipboard(
            context,
            text,
            context.i18n(AliceTranslationKey.callOverviewCopiedValue),
          ),
    );
  }
}

/// Copies [text] to clipboard and shows [message] in a snack bar.
Future<void> _copyToClipboard(
  BuildContext context,
  String text,
  String message,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

/// Selectable text for technical values (URLs, headers, bodies). It is always
/// laid out left to right, also in right to left languages, and aligned to
/// the reading start of the surrounding layout.
class _LtrSelectableText extends StatelessWidget {
  const _LtrSelectableText(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return SelectableText(
      text,
      textDirection: TextDirection.ltr,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      style: style,
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

    return _OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AliceMethodBadge(method: call.method, fontSize: 14),
              const Spacer(),
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
          const SizedBox(height: 14),
          _LtrSelectableText(
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
              _InfoChip(
                icon: call.secure ? Icons.lock_outline : Icons.lock_open,
                text: call.secure ? 'HTTPS' : 'HTTP',
                color: AliceTheme.getStatusColor(
                  context,
                  call.secure ? 200 : 400,
                ),
              ),
              if (call.client.isNotEmpty)
                _InfoChip(
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
          () => _copyToClipboard(
            context,
            url,
            context.i18n(AliceTranslationKey.callOverviewCopied),
          ),
    );
  }
}

/// Small rounded label with an icon.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
    return _OutlinedCard(
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

/// Titled group of label/value rows.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color dividerColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.08,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        _OutlinedCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int index = 0; index < rows.length; index++) ...[
                if (index > 0) Divider(height: 1, color: dividerColor),
                rows[index],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Single label/value row. Value can be selected and copied.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.hasError = false,
  });

  final String label;
  final String value;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color errorColor = getUrlIssueColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _LtrSelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: hasError ? errorColor : theme.colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded container with a subtle fill and outline.
class _OutlinedCard extends StatelessWidget {
  const _OutlinedCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
