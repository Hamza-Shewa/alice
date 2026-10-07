import 'package:alice/model/alice_http_call.dart';

/// Kind of mistake found in a request URL.
enum AliceUrlIssueType {
  /// Port separated with a dot, e.g. `192.168.1.1.505`.
  portWithDot,

  /// No `/` between port and path, e.g. `192.168.1.1:505api/login`.
  missingSlashAfterPort,

  /// No `/` between IP address and path, e.g. `192.168.1.1api/login`.
  missingSlashAfterHost,

  /// No `/` after API version segment, e.g. `/v1login`.
  missingSlashAfterVersion,

  /// IP address with wrong number of parts or a part above 255.
  invalidIp,

  /// Empty path segment, e.g. `/api//login`.
  doubleSlash,

  /// URL contains whitespace.
  whitespace,

  /// URL has no `http://` or `https://` scheme.
  missingScheme,
}

/// Mistake found in a request URL, with a corrected URL when one can be
/// guessed.
class AliceUrlIssue {
  const AliceUrlIssue(this.type, {this.suggestion});

  final AliceUrlIssueType type;
  final String? suggestion;

  @override
  bool operator ==(Object other) =>
      other is AliceUrlIssue &&
      other.type == type &&
      other.suggestion == suggestion;

  @override
  int get hashCode => Object.hash(type, suggestion);

  @override
  String toString() => 'AliceUrlIssue($type, $suggestion)';
}

/// Detects common typos in request URLs, such as a port written with a dot
/// or a base URL joined to a path without `/`.
class AliceUrlValidator {
  AliceUrlValidator._();

  static final RegExp _urlRegExp = RegExp(
    r'^(?:([a-zA-Z][a-zA-Z0-9+.-]*):\/\/)?([^\/?#]*)([^?#]*)(.*)$',
  );
  static final RegExp _ipWithDotPortRegExp = RegExp(
    r'^((?:\d{1,3}\.){3}\d{1,3})\.(\d{1,5})$',
  );
  static final RegExp _hostWithDotPortRegExp = RegExp(
    r'^(.*[a-zA-Z-].*)\.(\d{2,5})$',
  );
  static final RegExp _ipGluedToPathRegExp = RegExp(
    r'^((?:\d{1,3}\.){3}\d{1,3})([a-zA-Z_].*)$',
  );
  static final RegExp _portGluedToPathRegExp = RegExp(r'^(\d+)([^\d].*)$');
  static final RegExp _numericHostRegExp = RegExp(r'^[\d.]+$');
  static final RegExp _versionGluedRegExp = RegExp(
    r'(^|\/)(v\d+)(?!(?:alpha|beta|rc)\d*(?:\/|$))([a-zA-Z][^\/]*)',
  );
  static final RegExp _whitespaceRegExp = RegExp(r'\s');

  /// Returns issues found in URL of [call]. Empty list means the URL looks
  /// fine.
  static List<AliceUrlIssue> validateCall(AliceHttpCall call) {
    if (call.uri.isNotEmpty) {
      return validate(call.uri);
    }
    if (call.server.isEmpty && call.endpoint.isEmpty) {
      return const [];
    }
    final String scheme = call.secure ? 'https' : 'http';
    return validate(
      '$scheme://${call.server}${call.endpoint}',
    ).where((issue) => issue.type != AliceUrlIssueType.missingScheme).toList();
  }

  /// Returns issues found in [url]. Empty list means the URL looks fine.
  static List<AliceUrlIssue> validate(String url) {
    final String trimmed = url.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    final List<AliceUrlIssue> issues = [];
    if (_whitespaceRegExp.hasMatch(url)) {
      issues.add(
        AliceUrlIssue(
          AliceUrlIssueType.whitespace,
          suggestion: url.replaceAll(_whitespaceRegExp, ''),
        ),
      );
    }

    final RegExpMatch? match = _urlRegExp.firstMatch(trimmed);
    if (match == null) {
      return issues;
    }
    final String? scheme = match.group(1);
    final String authority = match.group(2) ?? '';
    final String path = match.group(3) ?? '';
    final String rest = match.group(4) ?? '';
    final String prefix = scheme != null ? '$scheme://' : '';

    if (scheme == null) {
      issues.add(const AliceUrlIssue(AliceUrlIssueType.missingScheme));
    }

    // Skip userinfo and IPv6 literals, they are rare in API base URLs.
    final int userInfoEnd = authority.lastIndexOf('@');
    final String userInfo =
        userInfoEnd >= 0 ? authority.substring(0, userInfoEnd + 1) : '';
    final String hostPort = authority.substring(userInfoEnd + 1);
    if (hostPort.startsWith('[')) {
      _validatePath(issues, prefix + authority, path, rest);
      return issues;
    }

    final int colonIndex = hostPort.indexOf(':');
    final String host =
        colonIndex >= 0 ? hostPort.substring(0, colonIndex) : hostPort;
    final String? port =
        colonIndex >= 0 ? hostPort.substring(colonIndex + 1) : null;
    final String base = '$prefix$userInfo';

    // Top level domains are never numeric, so a trailing number after a dot
    // is a port typed with '.' instead of ':'.
    final RegExpMatch? dotPort =
        _ipWithDotPortRegExp.firstMatch(host) ??
        (port == null ? _hostWithDotPortRegExp.firstMatch(host) : null);
    final RegExpMatch? ipGlued = _ipGluedToPathRegExp.firstMatch(host);
    if (dotPort != null) {
      issues.add(
        AliceUrlIssue(
          AliceUrlIssueType.portWithDot,
          suggestion: '$base${dotPort.group(1)}:${dotPort.group(2)}$path$rest',
        ),
      );
    } else if (ipGlued != null && port == null) {
      issues.add(
        AliceUrlIssue(
          AliceUrlIssueType.missingSlashAfterHost,
          suggestion: '$base${ipGlued.group(1)}/${ipGlued.group(2)}$path$rest',
        ),
      );
    } else if (_numericHostRegExp.hasMatch(host) && !_isValidIpv4(host)) {
      issues.add(const AliceUrlIssue(AliceUrlIssueType.invalidIp));
    }

    final RegExpMatch? portGlued =
        port != null ? _portGluedToPathRegExp.firstMatch(port) : null;
    if (portGlued != null) {
      issues.add(
        AliceUrlIssue(
          AliceUrlIssueType.missingSlashAfterPort,
          suggestion:
              '$base$host:${portGlued.group(1)}/${portGlued.group(2)}'
              '$path$rest',
        ),
      );
    }

    _validatePath(issues, prefix + authority, path, rest);
    return issues;
  }

  /// Validates [path] part of the URL and adds found issues to [issues].
  static void _validatePath(
    List<AliceUrlIssue> issues,
    String origin,
    String path,
    String rest,
  ) {
    if (path.contains('//')) {
      issues.add(
        AliceUrlIssue(
          AliceUrlIssueType.doubleSlash,
          suggestion: '$origin${path.replaceAll(RegExp(r'\/{2,}'), '/')}$rest',
        ),
      );
    }
    if (_versionGluedRegExp.hasMatch(path)) {
      final String fixedPath = path.replaceAllMapped(
        _versionGluedRegExp,
        (match) => '${match.group(1)}${match.group(2)}/${match.group(3)}',
      );
      issues.add(
        AliceUrlIssue(
          AliceUrlIssueType.missingSlashAfterVersion,
          suggestion: '$origin$fixedPath$rest',
        ),
      );
    }
  }

  /// Returns true when [host] is a valid dotted IPv4 address.
  static bool _isValidIpv4(String host) {
    final List<String> parts = host.split('.');
    return parts.length == 4 &&
        parts.every((part) {
          final int? value = int.tryParse(part);
          return value != null && value >= 0 && value <= 255;
        });
  }
}
