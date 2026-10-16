import 'package:netlens/helper/netlens_json_tree.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_json_viewer.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_url_issue_banner.dart';
import 'package:netlens/utils/netlens_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Returns [text] without trailing colon.
String netLensStripColon(String text) =>
    text.replaceFirst(RegExp(r':\s*$'), '');

/// Titled card with free-form content, used for request and response data.
class NetLensDetailSection extends StatelessWidget {
  const NetLensDetailSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NetLensSectionTitle(title: title),
        NetLensOutlinedCard(
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
class NetLensSectionTitle extends StatelessWidget {
  const NetLensSectionTitle({super.key, required this.title});

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
class NetLensGroup extends StatelessWidget {
  const NetLensGroup({super.key, required this.title, required this.child});

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
class NetLensKeyValueList extends StatelessWidget {
  const NetLensKeyValueList({
    super.key,
    required this.values,
    this.emptyText = '-',
  });

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
                NetLensLtrText(
                  entry.key,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                NetLensLtrText(entry.value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}

/// Monospace block for bodies and errors, with copy and show more actions.
///
/// An expanded block is kept alive inside lazy lists, so it doesn't collapse
/// and lay out its text again after scrolling out of view and back.
class NetLensCodeBlock extends StatefulWidget {
  const NetLensCodeBlock({super.key, required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  State<NetLensCodeBlock> createState() => _NetLensCodeBlockState();
}

class _NetLensCodeBlockState extends State<NetLensCodeBlock>
    with AutomaticKeepAliveClientMixin {
  static const int _collapsedLines = 15;
  static const int _collapsedChars = 1500;

  bool _expanded = false;
  late String _collapsedPreview;
  late bool _isLong;

  @override
  bool get wantKeepAlive => _expanded;

  @override
  void initState() {
    super.initState();
    _computePreview();
  }

  @override
  void didUpdateWidget(covariant NetLensCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _computePreview();
    }
  }

  void _computePreview() {
    final String text = widget.text;
    final int maxScan =
        text.length > _collapsedChars ? _collapsedChars : text.length;
    int newlineCount = 0;
    int cutIndex = maxScan;

    for (int i = 0; i < maxScan; i++) {
      if (text.codeUnitAt(i) == 0x0A) {
        newlineCount++;
        if (newlineCount >= _collapsedLines) {
          cutIndex = i;
          break;
        }
      }
    }

    _isLong = newlineCount >= _collapsedLines || text.length > _collapsedChars;
    _collapsedPreview = _isLong ? '${text.substring(0, cutIndex)}\n…' : text;
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    updateKeepAlive();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData theme = Theme.of(context);
    final bool isLong = _isLong;
    final String shownText =
        (isLong && !_expanded) ? _collapsedPreview : widget.text;

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
                  child: Text(
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
                child: NetLensCopyIconButton(text: widget.text),
              ),
            ],
          ),
          if (isLong)
            TextButton(
              onPressed: _toggleExpanded,
              child: Text(
                context.i18n(
                  _expanded
                      ? NetLensTranslationKey.callOverviewShowLess
                      : NetLensTranslationKey.callOverviewShowMore,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icon button which copies [text] to clipboard and confirms with snack bar.
class NetLensCopyIconButton extends StatelessWidget {
  const NetLensCopyIconButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy, size: 18),
      visualDensity: VisualDensity.compact,
      tooltip: context.i18n(NetLensTranslationKey.callOverviewCopy),
      onPressed:
          () => netLensCopyToClipboard(
            context,
            text,
            context.i18n(NetLensTranslationKey.callOverviewCopiedValue),
          ),
    );
  }
}

/// Copies [text] to clipboard and shows [message] in a snack bar.
Future<void> netLensCopyToClipboard(
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

/// Text for technical values (URLs, headers, bodies). It is always laid out
/// left to right, also in right to left languages, and aligned to the reading
/// start of the surrounding layout. It is a plain [Text], so it is cheap to
/// build; wrap the screen in a `SelectionArea` to make it selectable.
class NetLensLtrText extends StatelessWidget {
  const NetLensLtrText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Text(
      text,
      textDirection: TextDirection.ltr,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      style: style,
    );
  }
}

/// Rounded container with a subtle fill and outline.
class NetLensOutlinedCard extends StatelessWidget {
  const NetLensOutlinedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Own layer: cards are static while scrolling, so they are painted once.
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.03),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

/// Small rounded label with an icon.
class NetLensInfoChip extends StatelessWidget {
  const NetLensInfoChip({
    super.key,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

/// Titled group of label/value rows.
class NetLensInfoSection extends StatelessWidget {
  const NetLensInfoSection({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<NetLensInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color dividerColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.08,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NetLensSectionTitle(title: title),
        NetLensOutlinedCard(
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
class NetLensInfoRow extends StatelessWidget {
  const NetLensInfoRow({
    super.key,
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
            child: NetLensLtrText(
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

/// Card with a title, an optional counter and an optional action, whose
/// content can be collapsed. Used for long lists such as headers.
class NetLensCollapsibleSection extends StatefulWidget {
  const NetLensCollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.count,
    this.action,
    this.initiallyExpanded = true,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  /// Number displayed next to the title, for example number of headers.
  final int? count;

  /// Widget displayed at the end of the header, for example a copy button.
  final Widget? action;
  final bool initiallyExpanded;

  @override
  State<NetLensCollapsibleSection> createState() =>
      _NetLensCollapsibleSectionState();
}

class _NetLensCollapsibleSectionState extends State<NetLensCollapsibleSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return NetLensOutlinedCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: muted),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.count != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.count}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (widget.action != null) widget.action!,
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.expand_more, color: muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child:
                _expanded
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: widget.child,
                    )
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Code block with a formatted HTTP body. A JSON object or array is shown in
/// a collapsible tree, which can be switched to the formatted text.
/// Formatting a body (JSON decode and pretty print) is expensive, so the result is cached until the body, its
/// content type or the language changes. The block is kept alive inside lazy
/// lists, so scrolling it out of view and back doesn't format it again.
class NetLensFormattedBodyBlock extends StatefulWidget {
  const NetLensFormattedBodyBlock({
    super.key,
    required this.body,
    required this.contentType,
  });

  final dynamic body;
  final String? contentType;

  @override
  State<NetLensFormattedBodyBlock> createState() =>
      _NetLensFormattedBodyBlockState();
}

class _NetLensFormattedBodyBlockState extends State<NetLensFormattedBodyBlock>
    with AutomaticKeepAliveClientMixin {
  String? _text;
  dynamic _json;
  dynamic _body;
  String? _contentType;
  String? _language;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final String language = NetLensLanguage.current.value;
    if (_text == null ||
        !identical(_body, widget.body) ||
        _contentType != widget.contentType ||
        _language != language) {
      _body = widget.body;
      _contentType = widget.contentType;
      _language = language;
      _json = NetLensJsonTree.tryDecode(widget.body);
      _text =
          _json != null &&
                  !(widget.body is String && widget.body.contains('\n'))
              ? NetLensJsonTree.copyText(_json)
              : NetLensParser.formatBody(
                context: context,
                body: widget.body,
                contentType: widget.contentType,
              );
    }
    final dynamic json = _json;
    final bool hasChildren =
        json is Map ? json.isNotEmpty : (json is List && json.isNotEmpty);
    if (hasChildren) {
      return NetLensJsonViewer(json: json, rawText: _text!);
    }
    return NetLensCodeBlock(text: _text!);
  }
}
