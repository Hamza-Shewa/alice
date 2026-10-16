import 'package:alice/helper/alice_call_filter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Row of quick filter chips above the calls list: status groups, methods
/// and hosts of the caught calls.
class AliceCallFilterBar extends StatelessWidget {
  const AliceCallFilterBar({
    super.key,
    required this.calls,
    required this.filter,
    required this.onChanged,
  });

  /// All calls, used to offer only methods and hosts which occur.
  final List<AliceHttpCall> calls;
  final AliceCallFilter filter;
  final void Function(AliceCallFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String> methods =
        {
            for (final AliceHttpCall call in calls) call.method.toUpperCase(),
            ...filter.methods,
          }.where((String method) => method.isNotEmpty).toList()
          ..sort();
    final List<String> hosts =
        {
            for (final AliceHttpCall call in calls) call.server,
            ...filter.hosts,
          }.where((String host) => host.isNotEmpty).toList()
          ..sort();

    return SizedBox(
      height: 48,
      child: ListView(
        key: const Key('alice_filter_bar'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          if (filter.hasQuickFilters) ...[
            ActionChip(
              key: const Key('alice_filter_clear'),
              avatar: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(context.i18n(AliceTranslationKey.filtersClear)),
              onPressed: () => onChanged(filter.clearQuickFilters()),
            ),
            const SizedBox(width: 8),
          ],
          for (final AliceCallStatusGroup group
              in AliceCallStatusGroup.values) ...[
            _StatusChip(
              group: group,
              selected: filter.statusGroups.contains(group),
              onSelected:
                  (bool selected) => onChanged(
                    filter.copyWith(
                      statusGroups: _toggle(
                        filter.statusGroups,
                        group,
                        selected,
                      ),
                    ),
                  ),
            ),
            const SizedBox(width: 8),
          ],
          if (methods.length > 1)
            for (final String method in methods) ...[
              FilterChip(
                key: Key('alice_filter_method_$method'),
                label: Text(method),
                selected: filter.methods.contains(method),
                onSelected:
                    (bool selected) => onChanged(
                      filter.copyWith(
                        methods: _toggle(filter.methods, method, selected),
                      ),
                    ),
              ),
              const SizedBox(width: 8),
            ],
          if (hosts.length > 1)
            _HostChip(hosts: hosts, filter: filter, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Returns copy of [values] with [value] added when [selected], otherwise
/// removed.
Set<T> _toggle<T>(Set<T> values, T value, bool selected) =>
    selected ? {...values, value} : ({...values}..remove(value));

/// Chip of one status group, colored like the status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.group,
    required this.selected,
    required this.onSelected,
  });

  final AliceCallStatusGroup group;
  final bool selected;
  final void Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (group) {
      AliceCallStatusGroup.success => AliceTheme.getStatusColor(context, 200),
      AliceCallStatusGroup.redirection => AliceTheme.getStatusColor(
        context,
        300,
      ),
      AliceCallStatusGroup.clientError => AliceTheme.getStatusColor(
        context,
        400,
      ),
      AliceCallStatusGroup.serverError ||
      AliceCallStatusGroup.failed => AliceTheme.getStatusColor(context, 500),
      AliceCallStatusGroup.pending => AliceTheme.grey,
    };
    final String label = switch (group) {
      AliceCallStatusGroup.success => '2xx',
      AliceCallStatusGroup.redirection => '3xx',
      AliceCallStatusGroup.clientError => '4xx',
      AliceCallStatusGroup.serverError => '5xx',
      AliceCallStatusGroup.failed => context.i18n(
        AliceTranslationKey.filtersFailed,
      ),
      AliceCallStatusGroup.pending => context.i18n(
        AliceTranslationKey.filtersPending,
      ),
    };
    return FilterChip(
      key: Key('alice_filter_status_${group.name}'),
      avatar: selected ? null : Icon(Icons.circle, size: 10, color: color),
      label: Text(label),
      selected: selected,
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      onSelected: onSelected,
    );
  }
}

/// Chip which opens a menu where hosts can be picked.
class _HostChip extends StatelessWidget {
  const _HostChip({
    required this.hosts,
    required this.filter,
    required this.onChanged,
  });

  final List<String> hosts;
  final AliceCallFilter filter;
  final void Function(AliceCallFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    final Set<String> selected = filter.hosts;
    final String label =
        selected.isEmpty
            ? context.i18n(AliceTranslationKey.filtersAllHosts)
            : selected.length == 1
            ? selected.first
            : '${context.i18n(AliceTranslationKey.filtersHost)} (${selected.length})';
    return PopupMenuButton<String>(
      key: const Key('alice_filter_hosts'),
      tooltip: context.i18n(AliceTranslationKey.filtersHost),
      onSelected:
          (String host) => onChanged(
            filter.copyWith(
              hosts: _toggle(selected, host, !selected.contains(host)),
            ),
          ),
      itemBuilder:
          (BuildContext context) => [
            for (final String host in hosts)
              CheckedPopupMenuItem<String>(
                value: host,
                checked: selected.contains(host),
                child: Text(host, overflow: TextOverflow.ellipsis),
              ),
          ],
      child: IgnorePointer(
        child: FilterChip(
          avatar: const Icon(Icons.dns_outlined, size: 18),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
          selected: selected.isNotEmpty,
          showCheckmark: false,
          onSelected: (_) {},
        ),
      ),
    );
  }
}
