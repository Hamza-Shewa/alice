import 'package:netlens/helper/netlens_call_filter.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Row of quick filter chips above the calls list: status groups, methods
/// and hosts of the caught calls.
class NetLensCallFilterBar extends StatelessWidget {
  const NetLensCallFilterBar({
    super.key,
    required this.calls,
    required this.filter,
    required this.onChanged,
  });

  /// All calls, used to offer only methods and hosts which occur.
  final List<NetLensHttpCall> calls;
  final NetLensCallFilter filter;
  final void Function(NetLensCallFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String> methods =
        {
            for (final NetLensHttpCall call in calls) call.method.toUpperCase(),
            ...filter.methods,
          }.where((String method) => method.isNotEmpty).toList()
          ..sort();
    final List<String> hosts =
        {
            for (final NetLensHttpCall call in calls) call.server,
            ...filter.hosts,
          }.where((String host) => host.isNotEmpty).toList()
          ..sort();

    return SizedBox(
      height: 48,
      child: ListView(
        key: const Key('netlens_filter_bar'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          if (filter.hasQuickFilters) ...[
            ActionChip(
              key: const Key('netlens_filter_clear'),
              avatar: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(context.i18n(NetLensTranslationKey.filtersClear)),
              onPressed: () => onChanged(filter.clearQuickFilters()),
            ),
            const SizedBox(width: 8),
          ],
          for (final NetLensCallStatusGroup group
              in NetLensCallStatusGroup.values) ...[
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
                key: Key('netlens_filter_method_$method'),
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

  final NetLensCallStatusGroup group;
  final bool selected;
  final void Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (group) {
      NetLensCallStatusGroup.success => NetLensTheme.getStatusColor(
        context,
        200,
      ),
      NetLensCallStatusGroup.redirection => NetLensTheme.getStatusColor(
        context,
        300,
      ),
      NetLensCallStatusGroup.clientError => NetLensTheme.getStatusColor(
        context,
        400,
      ),
      NetLensCallStatusGroup.serverError || NetLensCallStatusGroup.failed =>
        NetLensTheme.getStatusColor(context, 500),
      NetLensCallStatusGroup.pending => NetLensTheme.grey,
    };
    final String label = switch (group) {
      NetLensCallStatusGroup.success => '2xx',
      NetLensCallStatusGroup.redirection => '3xx',
      NetLensCallStatusGroup.clientError => '4xx',
      NetLensCallStatusGroup.serverError => '5xx',
      NetLensCallStatusGroup.failed => context.i18n(
        NetLensTranslationKey.filtersFailed,
      ),
      NetLensCallStatusGroup.pending => context.i18n(
        NetLensTranslationKey.filtersPending,
      ),
    };
    return FilterChip(
      key: Key('netlens_filter_status_${group.name}'),
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
  final NetLensCallFilter filter;
  final void Function(NetLensCallFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    final Set<String> selected = filter.hosts;
    final String label =
        selected.isEmpty
            ? context.i18n(NetLensTranslationKey.filtersAllHosts)
            : selected.length == 1
            ? selected.first
            : '${context.i18n(NetLensTranslationKey.filtersHost)} (${selected.length})';
    return PopupMenuButton<String>(
      key: const Key('netlens_filter_hosts'),
      tooltip: context.i18n(NetLensTranslationKey.filtersHost),
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
