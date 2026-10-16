import 'dart:convert' show jsonEncode;

import 'package:alice/helper/alice_json_tree.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// How a JSON body is shown.
enum _AliceJsonViewMode { tree, raw }

/// Viewer of a JSON body: a collapsible tree with search, or the formatted
/// text. Values and their paths can be copied from the tree.
class AliceJsonViewer extends StatefulWidget {
  const AliceJsonViewer({super.key, required this.json, required this.rawText});

  /// Decoded body, a map or a list.
  final dynamic json;

  /// Formatted body shown in the raw mode.
  final String rawText;

  @override
  State<AliceJsonViewer> createState() => _AliceJsonViewerState();
}

class _AliceJsonViewerState extends State<AliceJsonViewer> {
  /// Rows rendered at once. A fully expanded large body would otherwise
  /// build thousands of rows.
  static const int _rowsPerPage = 500;

  _AliceJsonViewMode _mode = _AliceJsonViewMode.tree;
  late Set<String> _expanded;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _matches = const {};
  int _rowLimit = _rowsPerPage;

  /// The search field is shown on demand: a text field is costly in lists
  /// which scroll, and most bodies are read without searching.
  bool _searchVisible = false;

  void _toggleSearch() {
    setState(() => _searchVisible = !_searchVisible);
    if (!_searchVisible) {
      _searchController.clear();
      _search('');
    }
  }

  @override
  void initState() {
    super.initState();
    _expanded = AliceJsonTree.initiallyExpanded(widget.json);
  }

  @override
  void didUpdateWidget(covariant AliceJsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.json, widget.json)) {
      _expanded = AliceJsonTree.initiallyExpanded(widget.json);
      _search(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _matches = AliceJsonTree.search(widget.json, query);
      if (_matches.isNotEmpty) {
        _expanded = {
          ..._expanded,
          ...AliceJsonTree.ancestorsOf(widget.json, _matches),
        };
      }
    });
  }

  void _toggle(String path) => setState(() {
    _expanded =
        _expanded.contains(path)
            ? ({..._expanded}..remove(path))
            : {..._expanded, path};
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            SegmentedButton<_AliceJsonViewMode>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: [
                ButtonSegment(
                  value: _AliceJsonViewMode.tree,
                  icon: const Icon(Icons.account_tree_outlined, size: 16),
                  label: Text(context.i18n(AliceTranslationKey.jsonViewTree)),
                ),
                ButtonSegment(
                  value: _AliceJsonViewMode.raw,
                  icon: const Icon(Icons.notes, size: 16),
                  label: Text(context.i18n(AliceTranslationKey.jsonViewRaw)),
                ),
              ],
              selected: {_mode},
              onSelectionChanged:
                  (Set<_AliceJsonViewMode> selection) =>
                      setState(() => _mode = selection.first),
            ),
            if (_mode == _AliceJsonViewMode.tree)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _searchVisible ? Icons.search_off : Icons.search,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: context.i18n(AliceTranslationKey.jsonSearchHint),
                    isSelected: _searchVisible,
                    onPressed: _toggleSearch,
                  ),
                  IconButton(
                    icon: const Icon(Icons.unfold_more, size: 20),
                    visualDensity: VisualDensity.compact,
                    tooltip: context.i18n(AliceTranslationKey.jsonExpandAll),
                    onPressed:
                        () => setState(
                          () =>
                              _expanded = AliceJsonTree.allContainers(
                                widget.json,
                              ),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.unfold_less, size: 20),
                    visualDensity: VisualDensity.compact,
                    tooltip: context.i18n(AliceTranslationKey.jsonCollapseAll),
                    onPressed: () => setState(() => _expanded = {}),
                  ),
                  AliceCopyIconButton(text: widget.rawText),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_mode == _AliceJsonViewMode.raw)
          AliceCodeBlock(text: widget.rawText)
        else ...[
          if (_searchVisible) ...[
            TextField(
              controller: _searchController,
              onChanged: _search,
              autofocus: true,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: context.i18n(AliceTranslationKey.jsonSearchHint),
                border: const OutlineInputBorder(),
                suffixText:
                    _searchController.text.trim().isEmpty
                        ? null
                        : _matches.isEmpty
                        ? context.i18n(AliceTranslationKey.jsonNoMatches)
                        : context
                            .i18n(AliceTranslationKey.jsonMatches)
                            .replaceAll('[count]', '${_matches.length}'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _buildTree(context),
        ],
      ],
    );
  }

  Widget _buildTree(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<AliceJsonRow> rows = AliceJsonTree.visibleRows(
      widget.json,
      _expanded,
    );
    final List<AliceJsonRow> shownRows =
        rows.length > _rowLimit ? rows.sublist(0, _rowLimit) : rows;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      // JSON is always read left to right, also in RTL layouts.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final AliceJsonRow row in shownRows)
              _JsonRowWidget(
                key: ValueKey(row.path),
                row: row,
                highlighted: _matches.contains(row.path),
                onToggle: () => _toggle(row.path),
              ),
            if (rows.length > shownRows.length)
              TextButton(
                onPressed: () => setState(() => _rowLimit += _rowsPerPage),
                child: Text(
                  '${context.i18n(AliceTranslationKey.callOverviewShowMore)}'
                  ' (${rows.length - shownRows.length})',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One row of the tree: key and value, or key and size of a container.
class _JsonRowWidget extends StatelessWidget {
  const _JsonRowWidget({
    super.key,
    required this.row,
    required this.highlighted,
    required this.onToggle,
  });

  static const double _indent = 16;
  static const TextStyle _codeStyle = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Courier', 'Menlo'],
    fontSize: 12.5,
    height: 1.45,
  );

  final AliceJsonRow row;
  final bool highlighted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final Color keyColor =
        isDark ? const Color(0xff9cdcfe) : const Color(0xff0451a5);

    return Material(
      color:
          highlighted
              ? AliceTheme.orange.withValues(alpha: isDark ? 0.25 : 0.2)
              : Colors.transparent,
      child: InkWell(
        onTap: row.isContainer ? onToggle : () => _showMenu(context),
        onLongPress: () => _showMenu(context),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8 + row.depth * _indent, 2, 8, 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 18,
                child:
                    row.isContainer
                        ? Icon(
                          row.isExpanded
                              ? Icons.arrow_drop_down
                              : Icons.arrow_right,
                          size: 18,
                          color: muted,
                        )
                        : null,
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: _codeStyle.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: row.isMapEntry ? '"${row.label}"' : row.label,
                        style: TextStyle(
                          color: keyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ': ', style: TextStyle(color: muted)),
                      _valueSpan(context),
                    ],
                  ),
                  maxLines: row.isContainer ? 1 : 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Value colored by its type. Containers show their size.
  TextSpan _valueSpan(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final dynamic value = row.value;
    if (value is Map) {
      return TextSpan(
        text: '{${value.length}}',
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    if (value is List) {
      return TextSpan(
        text: '[${value.length}]',
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    final Color color = switch (value) {
      String() => isDark ? const Color(0xffce9178) : const Color(0xffa31515),
      num() => isDark ? const Color(0xffb5cea8) : const Color(0xff098658),
      _ => isDark ? const Color(0xff569cd6) : const Color(0xff0000ff),
    };
    String text;
    try {
      text = jsonEncode(value);
    } catch (_) {
      text = '$value';
    }
    return TextSpan(text: text, style: TextStyle(color: color));
  }

  Future<void> _showMenu(BuildContext context) async {
    final String copyValue = context.i18n(AliceTranslationKey.jsonCopyValue);
    final String copyPath = context.i18n(AliceTranslationKey.jsonCopyPath);
    final String copied = context.i18n(
      AliceTranslationKey.callOverviewCopiedValue,
    );
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final Offset topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final String? choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        topLeft & box.size,
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'value',
          child: Row(
            children: [
              const Icon(Icons.copy, size: 18),
              const SizedBox(width: 12),
              Text(copyValue),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'path',
          child: Row(
            children: [
              const Icon(Icons.route_outlined, size: 18),
              const SizedBox(width: 12),
              Text(copyPath),
            ],
          ),
        ),
      ],
    );
    if (choice == null || !context.mounted) {
      return;
    }
    await aliceCopyToClipboard(
      context,
      choice == 'path' ? row.path : AliceJsonTree.copyText(row.value),
      copied,
    );
  }
}
