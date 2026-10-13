import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/calls_list/model/alice_calls_list_sort_option.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Dialog which can be used to sort alice calls.
class AliceSortDialog extends StatefulWidget {
  final AliceCallsListSortOption sortOption;
  final bool sortAscending;

  const AliceSortDialog({
    super.key,
    required this.sortOption,
    required this.sortAscending,
  });

  @override
  State<AliceSortDialog> createState() => _AliceSortDialogState();
}

class _AliceSortDialogState extends State<AliceSortDialog> {
  late AliceCallsListSortOption _sortOption = widget.sortOption;
  late bool _sortAscending = widget.sortAscending;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = AliceTheme.getTheme(
      brightness: AliceTheme.resolveBrightness(context),
    );
    return Directionality(
      textDirection: AliceLanguage.textDirection,
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
                      color: AliceTheme.lightRed.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sort,
                      size: 20,
                      color: AliceTheme.lightRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.i18n(AliceTranslationKey.sortDialogTitle),
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
                    for (final AliceCallsListSortOption option
                        in AliceCallsListSortOption.values)
                      _OptionTile(
                        icon: _getIcon(option),
                        label: _getName(context: context, option: option),
                        selected: option == _sortOption,
                        onTap: () => setState(() => _sortOption = option),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      context.i18n(AliceTranslationKey.sortDialogOrder),
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
                              AliceTranslationKey.sortDialogDescending,
                            ),
                          ),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          icon: const Icon(Icons.arrow_upward, size: 18),
                          label: Text(
                            context.i18n(
                              AliceTranslationKey.sortDialogAscending,
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
                      context.i18n(AliceTranslationKey.sortDialogCancel),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AliceTheme.lightRed,
                      foregroundColor: AliceTheme.white,
                    ),
                    onPressed:
                        () => Navigator.of(context).pop(
                          AliceSortDialogResult(
                            sortOption: _sortOption,
                            sortAscending: _sortAscending,
                          ),
                        ),
                    child: Text(
                      context.i18n(AliceTranslationKey.sortDialogAccept),
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
  IconData _getIcon(AliceCallsListSortOption option) => switch (option) {
    AliceCallsListSortOption.time => Icons.schedule,
    AliceCallsListSortOption.responseTime => Icons.timer_outlined,
    AliceCallsListSortOption.responseCode => Icons.tag,
    AliceCallsListSortOption.responseSize => Icons.data_usage,
    AliceCallsListSortOption.endpoint => Icons.link,
  };

  /// Get sort option name based on [option].
  String _getName({
    required BuildContext context,
    required AliceCallsListSortOption option,
  }) {
    return switch (option) {
      AliceCallsListSortOption.time => context.i18n(
        AliceTranslationKey.sortDialogTime,
      ),
      AliceCallsListSortOption.responseTime => context.i18n(
        AliceTranslationKey.sortDialogResponseTime,
      ),
      AliceCallsListSortOption.responseCode => context.i18n(
        AliceTranslationKey.sortDialogResponseCode,
      ),
      AliceCallsListSortOption.responseSize => context.i18n(
        AliceTranslationKey.sortDialogResponseSize,
      ),
      AliceCallsListSortOption.endpoint => context.i18n(
        AliceTranslationKey.sortDialogEndpoint,
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
        selected ? AliceTheme.lightRed : theme.colorScheme.onSurfaceVariant;
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
                      ? AliceTheme.lightRed.withValues(alpha: 0.1)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    selected
                        ? AliceTheme.lightRed
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

/// Result of alice sort dialog.
class AliceSortDialogResult {
  final AliceCallsListSortOption sortOption;
  final bool sortAscending;

  AliceSortDialogResult({
    required this.sortOption,
    required this.sortAscending,
  });
}
