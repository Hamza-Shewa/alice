import 'package:equatable/equatable.dart';

/// Describes which values of a call are sensitive. Sensitive values are
/// replaced with [mask] in shared and exported calls (text log, cURL, HAR,
/// copy) and are hidden in the inspector until they are revealed.
///
/// Names are matched case-insensitively and exactly. Use [AliceRedaction.none]
/// to turn redaction off.
class AliceRedaction with Equatable {
  /// Headers which carry credentials in most APIs.
  static const Set<String> defaultHeaders = {
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token',
    'x-access-token',
    'x-csrf-token',
    'x-xsrf-token',
  };

  /// JSON body and form fields which carry credentials in most APIs.
  static const Set<String> defaultBodyFields = {
    'password',
    'new_password',
    'old_password',
    'passwd',
    'secret',
    'client_secret',
    'token',
    'access_token',
    'refresh_token',
    'id_token',
    'accesstoken',
    'refreshtoken',
    'api_key',
    'apikey',
  };

  /// Query parameters which carry credentials in most APIs.
  static const Set<String> defaultQueryParameters = {
    'token',
    'access_token',
    'api_key',
    'apikey',
    'key',
    'signature',
    'sig',
  };

  /// Default text which replaces a sensitive value.
  static const String defaultMask = '***';

  const AliceRedaction({
    this.headers = defaultHeaders,
    this.bodyFields = defaultBodyFields,
    this.queryParameters = defaultQueryParameters,
    this.mask = defaultMask,
  });

  /// Redaction which keeps every value.
  static const AliceRedaction none = AliceRedaction(
    headers: {},
    bodyFields: {},
    queryParameters: {},
  );

  /// Names of sensitive request and response headers.
  final Set<String> headers;

  /// Names of sensitive fields in JSON bodies and form data, at any depth.
  final Set<String> bodyFields;

  /// Names of sensitive URL query parameters.
  final Set<String> queryParameters;

  /// Text which replaces a sensitive value.
  final String mask;

  /// Returns true when nothing is redacted.
  bool get isEmpty =>
      headers.isEmpty && bodyFields.isEmpty && queryParameters.isEmpty;

  /// Returns true when header [name] is sensitive.
  bool isSensitiveHeader(String name) => _contains(headers, name);

  /// Returns true when body or form field [name] is sensitive.
  bool isSensitiveBodyField(String name) => _contains(bodyFields, name);

  /// Returns true when query parameter [name] is sensitive.
  bool isSensitiveQueryParameter(String name) =>
      _contains(queryParameters, name);

  static bool _contains(Set<String> names, String name) {
    if (names.isEmpty) {
      return false;
    }
    final String lowerCaseName = name.toLowerCase();
    return names.any((String value) => value.toLowerCase() == lowerCaseName);
  }

  @override
  List<Object?> get props => [headers, bodyFields, queryParameters, mask];
}
