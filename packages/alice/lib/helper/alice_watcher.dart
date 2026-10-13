import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// What a watched value means for the call.
enum AliceWatchOutcome {
  /// The call worked, like HTTP 200.
  success,

  /// The call failed, for example validation or a business rule, like HTTP
  /// 4xx.
  failed,

  /// The backend is broken or down, like HTTP 5xx.
  serverDown,
}

/// One value of a watched field and what it means.
class AliceWatchedValue {
  AliceWatchedValue({
    this.value = '',
    this.meaning = '',
    this.outcome = AliceWatchOutcome.success,
  });

  factory AliceWatchedValue.fromJson(Map<String, dynamic> json) =>
      AliceWatchedValue(
        value: '${json['value'] ?? ''}',
        meaning: '${json['meaning'] ?? ''}',
        outcome: AliceWatchOutcome.values.firstWhere(
          (AliceWatchOutcome outcome) => outcome.name == json['outcome'],
          orElse: () => AliceWatchOutcome.success,
        ),
      );

  /// Value compared with the value found in the response, as text.
  String value;

  /// Free text which explains the value.
  String meaning;
  AliceWatchOutcome outcome;

  Map<String, dynamic> toJson() => {
    'value': value,
    'meaning': meaning,
    'outcome': outcome.name,
  };
}

/// Field of the response body which carries the real result of the call.
class AliceWatchedField {
  AliceWatchedField({
    this.path = '',
    this.useAsStatus = false,
    List<AliceWatchedValue>? values,
  }) : values = values ?? [];

  factory AliceWatchedField.fromJson(Map<String, dynamic> json) =>
      AliceWatchedField(
        path: '${json['path'] ?? ''}',
        useAsStatus: json['useAsStatus'] == true,
        values: [
          for (final dynamic value in (json['values'] as List<dynamic>? ?? []))
            AliceWatchedValue.fromJson(value as Map<String, dynamic>),
        ],
      );

  /// Name of the field. Dots reach nested fields, for example `data.status`.
  String path;

  /// Whether the result is shown next to the HTTP status and used to detect
  /// failures.
  bool useAsStatus;
  final List<AliceWatchedValue> values;

  Map<String, dynamic> toJson() => {
    'path': path,
    'useAsStatus': useAsStatus,
    'values': [for (final AliceWatchedValue value in values) value.toJson()],
  };
}

/// Result of matching a response with a watched field.
class AliceWatchResult {
  const AliceWatchResult({
    required this.path,
    required this.value,
    required this.outcome,
    required this.meaning,
  });

  final String path;
  final String value;
  final AliceWatchOutcome outcome;
  final String meaning;
}

class _CachedResult {
  _CachedResult(this.body, this.version, this.result);

  final dynamic body;
  final int version;
  final AliceWatchResult? result;
}

/// Lets the user watch a field of response bodies. Some backends always answer
/// with HTTP 200 and report the real result in a field, for example
/// `{"type": 2, ...}`. A watched field which is used as status shows that
/// result next to the HTTP status.
class AliceWatcher extends ChangeNotifier {
  AliceWatcher._() : fields = defaultFields();

  static final AliceWatcher instance = AliceWatcher._();

  static const String _fileName = 'alice_watcher.json';

  /// Fields watched by default: the `type` field used by some backends, which
  /// is already used as status code.
  static List<AliceWatchedField> defaultFields() => [
    AliceWatchedField(
      path: 'type',
      useAsStatus: true,
      values: [
        AliceWatchedValue(
          value: '1',
          meaning: 'Success',
          outcome: AliceWatchOutcome.success,
        ),
        AliceWatchedValue(
          value: '2',
          meaning: 'Validation or business error',
          outcome: AliceWatchOutcome.failed,
        ),
        AliceWatchedValue(
          value: '3',
          meaning: 'Server error',
          outcome: AliceWatchOutcome.serverDown,
        ),
      ],
    ),
  ];

  final List<AliceWatchedField> fields;
  final Expando<_CachedResult> _cache = Expando<_CachedResult>();
  int _version = 0;
  bool _loaded = false;
  Timer? _saveDebounceTimer;

  /// Changes every time [fields] change. Used to refresh cached screens.
  int get version => _version;

  /// Call after any change of [fields]. Notifies listeners and debounces save.
  void changed() {
    _version++;
    notifyListeners();
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 300), _save);
  }

  /// Replaces watched fields with the default ones.
  void reset() {
    fields
      ..clear()
      ..addAll(defaultFields());
    changed();
  }

  /// Returns what the first field used as status says about [call], or null
  /// when no field matches or the response has no such field.
  AliceWatchResult? evaluate(AliceHttpCall call) {
    final dynamic body = call.response?.body;
    if (call.loading || body == null) {
      return null;
    }
    final _CachedResult? cached = _cache[call];
    if (cached != null &&
        cached.version == _version &&
        identical(cached.body, body)) {
      return cached.result;
    }
    final AliceWatchResult? result = _match(body);
    _cache[call] = _CachedResult(body, _version, result);
    return result;
  }

  AliceWatchResult? _match(dynamic body) {
    final List<AliceWatchedField> active = [
      for (final AliceWatchedField field in fields)
        if (field.useAsStatus && field.path.trim().isNotEmpty) field,
    ];
    if (active.isEmpty) {
      return null;
    }
    final dynamic json = _asJson(body);
    if (json == null) {
      return null;
    }
    for (final AliceWatchedField field in active) {
      final dynamic found = _lookup(json, field.path.trim());
      if (found == null) {
        continue;
      }
      final String text = _stringify(found);
      for (final AliceWatchedValue value in field.values) {
        if (value.value.trim().toLowerCase() == text.toLowerCase()) {
          return AliceWatchResult(
            path: field.path.trim(),
            value: text,
            outcome: value.outcome,
            meaning: value.meaning.trim(),
          );
        }
      }
    }
    return null;
  }

  dynamic _asJson(dynamic body) {
    if (body is Map || body is List) {
      return body;
    }
    if (body is String && body.trim().startsWith(RegExp(r'[{\[]'))) {
      try {
        return jsonDecode(body);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  dynamic _lookup(dynamic json, String path) {
    dynamic current = json;
    for (final String part in path.split('.')) {
      if (current is Map) {
        current = current[part];
      } else if (current is List) {
        final int? index = int.tryParse(part);
        current =
            index != null && index >= 0 && index < current.length
                ? current[index]
                : null;
      } else {
        return null;
      }
      if (current == null) {
        return null;
      }
    }
    return current is Map || current is List ? null : current;
  }

  String _stringify(dynamic value) {
    if (value is double && value == value.truncateToDouble()) {
      return '${value.toInt()}';
    }
    return '$value'.trim();
  }

  /// Loads saved fields once. Errors are ignored, defaults stay in that case
  /// (for example when the platform has no file system).
  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    try {
      final File file = await _file();
      if (!await file.exists()) {
        return;
      }
      final dynamic json = jsonDecode(await file.readAsString());
      final List<AliceWatchedField> loaded = [
        for (final dynamic field in json as List<dynamic>)
          AliceWatchedField.fromJson(field as Map<String, dynamic>),
      ];
      fields
        ..clear()
        ..addAll(loaded);
      _version++;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final File file = await _file();
      await file.writeAsString(
        jsonEncode([for (final AliceWatchedField f in fields) f.toJson()]),
      );
    } catch (_) {}
  }

  Future<File> _file() async {
    final Directory directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }
}