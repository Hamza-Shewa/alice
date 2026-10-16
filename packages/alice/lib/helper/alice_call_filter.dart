import 'package:alice/core/alice_http_status.dart';
import 'package:alice/helper/alice_graphql.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:equatable/equatable.dart';

/// Group of calls by result, used by the quick filters of the calls list.
enum AliceCallStatusGroup {
  success,
  redirection,
  clientError,
  serverError,
  failed,
  pending;

  /// Returns the group of [call].
  static AliceCallStatusGroup of(AliceHttpCall call) {
    if (call.loading) {
      return AliceCallStatusGroup.pending;
    }
    return switch (AliceHttpStatus.getCategory(call.response?.status)) {
      AliceHttpStatusCategory.success ||
      AliceHttpStatusCategory.informational => AliceCallStatusGroup.success,
      AliceHttpStatusCategory.redirection => AliceCallStatusGroup.redirection,
      AliceHttpStatusCategory.clientError => AliceCallStatusGroup.clientError,
      AliceHttpStatusCategory.serverError => AliceCallStatusGroup.serverError,
      AliceHttpStatusCategory.failed ||
      AliceHttpStatusCategory.unknown => AliceCallStatusGroup.failed,
    };
  }
}

/// Filter of the calls list: a search query and quick filters. A call passes
/// when it matches the query and one selected value of every quick filter
/// which has a selection.
class AliceCallFilter with Equatable {
  const AliceCallFilter({
    this.query = '',
    this.statusGroups = const {},
    this.methods = const {},
    this.hosts = const {},
  });

  /// Text searched in URL, method, status, GraphQL operation, headers and
  /// bodies, ignoring case.
  final String query;
  final Set<AliceCallStatusGroup> statusGroups;

  /// Upper case HTTP methods.
  final Set<String> methods;
  final Set<String> hosts;

  /// Returns true when a quick filter has a selection.
  bool get hasQuickFilters =>
      statusGroups.isNotEmpty || methods.isNotEmpty || hosts.isNotEmpty;

  /// Returns true when nothing is filtered.
  bool get isEmpty => query.trim().isEmpty && !hasQuickFilters;

  /// Returns calls of [calls] which pass this filter.
  List<AliceHttpCall> apply(List<AliceHttpCall> calls) =>
      isEmpty ? calls : calls.where(matches).toList();

  /// Returns true when [call] passes this filter.
  bool matches(AliceHttpCall call) {
    if (statusGroups.isNotEmpty &&
        !statusGroups.contains(AliceCallStatusGroup.of(call))) {
      return false;
    }
    if (methods.isNotEmpty && !methods.contains(call.method.toUpperCase())) {
      return false;
    }
    if (hosts.isNotEmpty && !hosts.contains(call.server)) {
      return false;
    }
    final String normalizedQuery = query.trim().toLowerCase();
    return normalizedQuery.isEmpty || _matchesQuery(call, normalizedQuery);
  }

  static bool _matchesQuery(AliceHttpCall call, String query) {
    bool has(Object? value) =>
        value != null && value.toString().toLowerCase().contains(query);
    bool hasInHeaders(Map<String, String>? headers) =>
        headers?.entries.any(
          (MapEntry<String, String> header) =>
              has(header.key) || has(header.value),
        ) ??
        false;

    return has(call.endpoint) ||
        has(call.server) ||
        has(call.method) ||
        has(call.uri) ||
        has(call.response?.status) ||
        has(AliceGraphQL.detect(call)?.title) ||
        hasInHeaders(call.request?.headers) ||
        hasInHeaders(call.response?.headers) ||
        has(call.request?.body) ||
        has(call.response?.body) ||
        has(call.error?.error);
  }

  AliceCallFilter copyWith({
    String? query,
    Set<AliceCallStatusGroup>? statusGroups,
    Set<String>? methods,
    Set<String>? hosts,
  }) => AliceCallFilter(
    query: query ?? this.query,
    statusGroups: statusGroups ?? this.statusGroups,
    methods: methods ?? this.methods,
    hosts: hosts ?? this.hosts,
  );

  /// Returns a copy without quick filters, keeping the query.
  AliceCallFilter clearQuickFilters() => AliceCallFilter(query: query);

  @override
  List<Object?> get props => [query, statusGroups, methods, hosts];
}
