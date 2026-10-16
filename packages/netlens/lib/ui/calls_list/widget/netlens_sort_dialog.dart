import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/calls_list/model/netlens_calls_list_sort_option.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Dialog which can be used to sort netLens calls.
class NetLensSortDialog extends StatefulWidget {
  final NetLensCallsListSortOption sortOption;
  final bool sortAscending;

  const NetLensSortDialog({
    super.key,
    required this.sortOption,
    required this.sortAscending,
  });

  @override
  State<NetLensSortDialog> createState() => _NetLensSortDialogState();
}

class _NetLensSortDialogState extends State<NetLensSortDialog> {
  late NetLensCallsListSortOption _sortOption = widget.sortOption;
  late bool _sortAscending = widget.sortAscending;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = NetLensTheme.getTheme(
      brightness: NetLensTheme.resolveBrightness(context),
    );
    return Directionality(
      textDirection: NetLensLanguage.textDirection,
      child: Theme(
        data: theme,
        // Builder gives the dialog the theme above, not the one of the app.
        child: Builder(builder: _buildDialog),
      ),
    );
  }

  Widget _buildDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: NetLensTheme.lightRed.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sort,
                      size: 20,
                      color: NetLensTheme.lightRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.i18n(NetLensTranslationKey.sortDialogTitle),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final NetLensCallsListSortOption option
                        in NetLensCallsListSortOption.values)
                      _OptionTile(
                        icon: _getIcon(option),
                        label: _getName(context: context, option: option),
                        selected: option == _sortOption,
                        onTap: () => setState(() => _sortOption = option),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      context.i18n(NetLensTranslationKey.sortDialogOrder),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment<bool>(
                          value: false,
                          icon: const Icon(Icons.arrow_downward, size: 18),
                          label: Text(
                            context.i18n(
                              NetLensTranslationKey.sortDialogDescending,
                            ),
                          ),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          icon: const Icon(Icons.arrow_upward, size: 18),
                          label: Text(
                            context.i18n(
                              NetLensTranslationKey.sortDialogAscending,
                            ),
                          ),
                        ),
                      ],
                      selected: {_sortAscending},
                      onSelectionChanged:
                          (Set<bool> value) =>
                              setState(() => _sortAscending = value.first),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(
                      context.i18n(NetLensTranslationKey.sortDialogCancel),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: NetLensTheme.lightRed,
                      foregroundColor: NetLensTheme.white,
                    ),
                    onPressed:
                        () => Navigator.of(context).pop(
                          NetLensSortDialogResult(
                            sortOption: _sortOption,
                            sortAscending: _sortAscending,
                          ),
                        ),
                    child: Text(
                      context.i18n(NetLensTranslationKey.sortDialogAccept),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get sort option icon based on [option].
  IconData _getIcon(NetLensCallsListSortOption option) => switch (option) {
    NetLensCallsListSortOption.time => Icons.schedule,
    NetLensCallsListSortOption.responseTime => Icons.timer_outlined,
    NetLensCallsListSortOption.responseCode => Icons.tag,
    NetLensCallsListSortOption.responseSize => Icons.data_usage,
    NetLensCallsListSortOption.endpoint => Icons.link,
  };

  /// Get sort option name based on [option].
  String _getName({
    required BuildContext context,
    required NetLensCallsListSortOption option,
  }) {
    return switch (option) {
      NetLensCallsListSortOption.time => context.i18n(
        NetLensTranslationKey.sortDialogTime,
      ),
      NetLensCallsListSortOption.responseTime => context.i18n(
        NetLensTranslationKey.sortDialogResponseTime,
      ),
      NetLensCallsListSortOption.responseCode => context.i18n(
        NetLensTranslationKey.sortDialogResponseCode,
      ),
      NetLensCallsListSortOption.responseSize => context.i18n(
        NetLensTranslationKey.sortDialogResponseSize,
      ),
      NetLensCallsListSortOption.endpoint => context.i18n(
        NetLensTranslationKey.sortDialogEndpoint,
      ),
    };
  }
}

/// One selectable sort option: icon, name and a check mark when selected.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color =
        selected ? NetLensTheme.lightRed : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color:
                  selected
                      ? NetLensTheme.lightRed.withValues(alpha: 0.1)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    selected
                        ? NetLensTheme.lightRed
                        : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Result of netLens sort dialog.
class NetLensSortDialogResult {
  final NetLensCallsListSortOption sortOption;
  final bool sortAscending;

  NetLensSortDialogResult({
    required this.sortOption,
    required this.sortAscending,
  });
}
