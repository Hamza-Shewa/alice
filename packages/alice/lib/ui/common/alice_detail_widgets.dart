import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_url_issue_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Returns [text] without trailing colon.
String aliceStripColon(String text) => text.replaceFirst(RegExp(r':\s*$'), '');

/// Titled card with free-form content, used for request and response data.
class AliceDetailSection extends StatelessWidget {
  const AliceDetailSection({
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
        AliceSectionTitle(title: title),
        AliceOutlinedCard(
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
class AliceSectionTitle extends StatelessWidget {
  const AliceSectionTitle({super.key, required this.title});

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
class AliceGroup extends StatelessWidget {
  const AliceGroup({super.key, required this.title, required this.child});

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
class AliceKeyValueList extends StatelessWidget {
  const AliceKeyValueList({
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
                AliceLtrSelectableText(
                  entry.key,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                AliceLtrSelectableText(
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
class AliceCodeBlock extends StatefulWidget {
  const AliceCodeBlock({super.key, required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  State<AliceCodeBlock> createState() => _AliceCodeBlockState();
}

class _AliceCodeBlockState extends State<AliceCodeBlock> {
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
                child: AliceCopyIconButton(text: widget.text),
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
class AliceCopyIconButton extends StatelessWidget {
  const AliceCopyIconButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy, size: 18),
      visualDensity: VisualDensity.compact,
      tooltip: context.i18n(AliceTranslationKey.callOverviewCopy),
      onPressed:
          () => aliceCopyToClipboard(
            context,
            text,
            context.i18n(AliceTranslationKey.callOverviewCopiedValue),
          ),
    );
  }
}

/// Copies [text] to clipboard and shows [message] in a snack bar.
Future<void> aliceCopyToClipboard(
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
class AliceLtrSelectableText extends StatelessWidget {
  const AliceLtrSelectableText(this.text, {super.key, this.style});

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

/// Rounded container with a subtle fill and outline.
class AliceOutlinedCard extends StatelessWidget {
  const AliceOutlinedCard({
    super.key,
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
