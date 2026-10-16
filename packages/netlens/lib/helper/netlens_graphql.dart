import 'dart:convert' show jsonDecode;

import 'package:netlens/model/netlens_http_call.dart';

/// Kind of a GraphQL operation.
enum NetLensGraphQLOperationType { query, mutation, subscription }

/// GraphQL operation sent by a call.
class NetLensGraphQLOperation {
  const NetLensGraphQLOperation({
    required this.type,
    this.name,
    this.batchSize = 1,
    this.hasErrors = false,
  });

  final NetLensGraphQLOperationType type;

  /// Name of the operation, or null for an anonymous operation.
  final String? name;

  /// Number of operations when the request sends a batch, otherwise 1.
  final int batchSize;

  /// True when the response has a non-empty `errors` list. GraphQL servers
  /// usually report errors with status 200.
  final bool hasErrors;

  /// Text which identifies the operation, for example "query GetUser" or
  /// "mutation Login +2" for a batch of three operations.
  String get title {
    final StringBuffer buffer = StringBuffer(type.name);
    if (name != null) {
      buffer.write(' $name');
    }
    if (batchSize > 1) {
      buffer.write(' +${batchSize - 1}');
    }
    return buffer.toString();
  }
}

/// Recognizes GraphQL calls: a POST with a JSON body which has a `query`
/// string, or a GET with a `query` parameter.
class NetLensGraphQL {
  NetLensGraphQL._();

  static final RegExp _operationRegExp = RegExp(
    r'^\s*(query|mutation|subscription)\b\s*([_A-Za-z][_0-9A-Za-z]*)?',
  );
  static final RegExp _commentRegExp = RegExp(r'#[^\n]*');

  /// Last results, so list rows don't decode the same body on every build.
  static final Expando<_Result> _cache = Expando<_Result>();

  /// Returns the GraphQL operation of [call], or null when [call] isn't a
  /// GraphQL call.
  static NetLensGraphQLOperation? detect(NetLensHttpCall call) {
    final _Result? cached = _cache[call];
    if (cached != null &&
        identical(cached.requestBody, call.request?.body) &&
        identical(cached.responseBody, call.response?.body)) {
      return cached.operation;
    }
    final NetLensGraphQLOperation? operation = _detect(call);
    _cache[call] = _Result(call.request?.body, call.response?.body, operation);
    return operation;
  }

  static NetLensGraphQLOperation? _detect(NetLensHttpCall call) {
    final List<Map<dynamic, dynamic>> payloads = _getPayloads(call);
    if (payloads.isEmpty) {
      return null;
    }
    final Map<dynamic, dynamic> first = payloads.first;
    final String query = first['query'] as String;
    final RegExpMatch? match = _operationRegExp.firstMatch(
      query.replaceAll(_commentRegExp, ''),
    );
    final dynamic rawName = first['operationName'];
    final String? operationName = rawName is String ? rawName : null;
    return NetLensGraphQLOperation(
      type: NetLensGraphQLOperationType.values.firstWhere(
        (NetLensGraphQLOperationType type) => type.name == match?.group(1),
        orElse: () => NetLensGraphQLOperationType.query,
      ),
      name:
          (operationName != null && operationName.isNotEmpty)
              ? operationName
              : match?.group(2),
      batchSize: payloads.length,
      hasErrors: _hasErrors(call.response?.body),
    );
  }

  /// Returns GraphQL payloads (maps with `query`) sent by [call].
  static List<Map<dynamic, dynamic>> _getPayloads(NetLensHttpCall call) {
    if (call.method.toUpperCase() == 'GET') {
      final dynamic query = call.request?.queryParameters['query'];
      if (query is String && _looksLikeDocument(query)) {
        return [
          {
            'query': query,
            'operationName': call.request?.queryParameters['operationName'],
          },
        ];
      }
      return const [];
    }
    final dynamic body = _decode(call.request?.body);
    final List<dynamic> items = body is List ? body : [body];
    final List<Map<dynamic, dynamic>> payloads = [
      for (final dynamic item in items)
        if (item is Map &&
            item['query'] is String &&
            _looksLikeDocument(item['query'] as String) &&
            (item['operationName'] == null || item['operationName'] is String))
          item,
    ];
    return payloads.length == items.length ? payloads : const [];
  }

  /// Returns true when [query] starts like a GraphQL document.
  static bool _looksLikeDocument(String query) {
    final String trimmed = query.replaceAll(_commentRegExp, '').trimLeft();
    return trimmed.startsWith('{') ||
        trimmed.startsWith('fragment') ||
        _operationRegExp.hasMatch(trimmed);
  }

  static bool _hasErrors(dynamic responseBody) {
    final dynamic body = _decode(responseBody);
    final List<dynamic> items = body is List ? body : [body];
    return items.any(
      (dynamic item) =>
          item is Map && item['errors'] is List && item['errors'].isNotEmpty,
    );
  }

  static dynamic _decode(dynamic body) {
    if (body is String) {
      final String trimmed = body.trimLeft();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        return null;
      }
      try {
        return jsonDecode(body);
      } on FormatException {
        return null;
      }
    }
    return body;
  }
}

class _Result {
  const _Result(this.requestBody, this.responseBody, this.operation);

  final dynamic requestBody;
  final dynamic responseBody;
  final NetLensGraphQLOperation? operation;
}
