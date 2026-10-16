import 'dart:convert' show JsonEncoder, jsonDecode, jsonEncode;

/// One visible row of a JSON tree.
class AliceJsonRow {
  const AliceJsonRow({
    required this.path,
    required this.depth,
    required this.label,
    required this.value,
    required this.isExpanded,
    this.isMapEntry = true,
  });

  /// Path of the value, for example `$.data[0].name`.
  final String path;

  /// Nesting level, 0 for children of the root.
  final int depth;

  /// Key in a map, or index in a list.
  final String label;
  final dynamic value;
  final bool isExpanded;

  /// True for a value in a map, false for an item of a list.
  final bool isMapEntry;

  /// Returns true when the value is a map or a list.
  bool get isContainer => value is Map || value is List;

  /// Number of children of a map or a list, otherwise 0.
  int get childCount => switch (value) {
    final Map<dynamic, dynamic> map => map.length,
    final List<dynamic> list => list.length,
    _ => 0,
  };
}

/// Logic of the collapsible JSON viewer: decoding, visible rows, paths and
/// search. It has no UI, so it can be tested on its own.
class AliceJsonTree {
  AliceJsonTree._();

  /// Path of the root value.
  static const String rootPath = r'$';

  static final RegExp _identifierRegExp = RegExp(r'^[A-Za-z_$][\w$]*$');

  /// Returns [body] as a map or a list when it is one or when it is a string
  /// with a JSON object or array, otherwise null.
  static dynamic tryDecode(dynamic body) {
    if (body is Map || body is List) {
      return body;
    }
    if (body is String) {
      final String trimmed = body.trimLeft();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        return null;
      }
      try {
        final dynamic decoded = jsonDecode(body);
        return decoded is Map || decoded is List ? decoded : null;
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  /// Returns path of child [key] of the value at [parentPath].
  static String childPath(String parentPath, dynamic key) {
    if (key is int) {
      return '$parentPath[$key]';
    }
    final String name = '$key';
    return _identifierRegExp.hasMatch(name)
        ? '$parentPath.$name'
        : '$parentPath[${jsonEncode(name)}]';
  }

  /// Returns rows which are visible when the containers at [expanded] paths
  /// are expanded. The root itself has no row.
  static List<AliceJsonRow> visibleRows(dynamic root, Set<String> expanded) {
    final List<AliceJsonRow> rows = [];
    void visit(dynamic value, String path, int depth) {
      for (final (dynamic key, dynamic child) in _children(value)) {
        final String itemPath = childPath(path, key);
        final bool isExpanded = expanded.contains(itemPath);
        rows.add(
          AliceJsonRow(
            path: itemPath,
            depth: depth,
            label: '$key',
            value: child,
            isExpanded: isExpanded,
            isMapEntry: key is! int,
          ),
        );
        if (isExpanded) {
          visit(child, itemPath, depth + 1);
        }
      }
    }

    visit(root, rootPath, 0);
    return rows;
  }

  /// Returns paths of containers which start expanded: containers up to
  /// [depth] levels deep with at most [maxChildren] children.
  static Set<String> initiallyExpanded(
    dynamic root, {
    int depth = 1,
    int maxChildren = 50,
  }) {
    final Set<String> paths = {};
    void visit(dynamic value, String path, int level) {
      if (level >= depth) {
        return;
      }
      for (final (dynamic key, dynamic child) in _children(value)) {
        final String itemPath = childPath(path, key);
        final int count = _children(child).length;
        if (count > 0 && count <= maxChildren) {
          paths.add(itemPath);
          visit(child, itemPath, level + 1);
        }
      }
    }

    visit(root, rootPath, 0);
    return paths;
  }

  /// Returns paths of all containers.
  static Set<String> allContainers(dynamic root) {
    final Set<String> paths = {};
    void visit(dynamic value, String path) {
      for (final (dynamic key, dynamic child) in _children(value)) {
        final String itemPath = childPath(path, key);
        if (child is Map || child is List) {
          paths.add(itemPath);
          visit(child, itemPath);
        }
      }
    }

    visit(root, rootPath);
    return paths;
  }

  /// Returns paths of values whose key, or value when it isn't a container,
  /// contains [query], ignoring case.
  static Set<String> search(dynamic root, String query) {
    final String normalizedQuery = query.trim().toLowerCase();
    final Set<String> matches = {};
    if (normalizedQuery.isEmpty) {
      return matches;
    }
    void visit(dynamic value, String path) {
      for (final (dynamic key, dynamic child) in _children(value)) {
        final String itemPath = childPath(path, key);
        final bool keyMatches =
            key is String && key.toLowerCase().contains(normalizedQuery);
        final bool valueMatches =
            child is! Map &&
            child is! List &&
            '$child'.toLowerCase().contains(normalizedQuery);
        if (keyMatches || valueMatches) {
          matches.add(itemPath);
        }
        visit(child, itemPath);
      }
    }

    visit(root, rootPath);
    return matches;
  }

  /// Returns paths of containers which hold the values at [paths], so
  /// expanding them shows those values.
  static Set<String> ancestorsOf(dynamic root, Set<String> paths) {
    final Set<String> ancestors = {};
    bool visit(dynamic value, String path) {
      bool containsMatch = false;
      for (final (dynamic key, dynamic child) in _children(value)) {
        final String itemPath = childPath(path, key);
        final bool childContains = visit(child, itemPath);
        if (childContains) {
          ancestors.add(itemPath);
        }
        containsMatch =
            containsMatch || childContains || paths.contains(itemPath);
      }
      return containsMatch;
    }

    visit(root, rootPath);
    return ancestors;
  }

  /// Returns [value] as text to copy: containers as indented JSON, strings
  /// without quotes and other values as JSON.
  static String copyText(dynamic value) {
    if (value is String) {
      return value;
    }
    try {
      return value is Map || value is List
          ? JsonEncoder.withIndent('  ').convert(value)
          : jsonEncode(value);
    } catch (_) {
      return '$value';
    }
  }

  static Iterable<(dynamic, dynamic)> _children(dynamic value) sync* {
    if (value is Map) {
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        yield (entry.key, entry.value);
      }
    } else if (value is List) {
      for (int index = 0; index < value.length; index++) {
        yield (index, value[index]);
      }
    }
  }
}
