import 'package:alice/helper/alice_url_validator.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:test/test.dart';

void main() {
  List<AliceUrlIssueType> types(String url) =>
      AliceUrlValidator.validate(url).map((issue) => issue.type).toList();

  group('AliceUrlValidator', () {
    test('should accept valid URLs', () {
      for (final url in [
        'http://192.168.1.1:505/api/login',
        'https://api.example.com/v1/users?page=2',
        'https://api.example.com/v1beta/users',
        'http://localhost:8080/',
        'https://example.com',
        'http://[::1]:8080/api',
      ]) {
        expect(AliceUrlValidator.validate(url), isEmpty, reason: url);
      }
    });

    test('should detect port written with dot', () {
      expect(AliceUrlValidator.validate('http://192.168.1.1.505/api/login'), [
        const AliceUrlIssue(
          AliceUrlIssueType.portWithDot,
          suggestion: 'http://192.168.1.1:505/api/login',
        ),
      ]);
      expect(AliceUrlValidator.validate('https://api.example.com.8080/x'), [
        const AliceUrlIssue(
          AliceUrlIssueType.portWithDot,
          suggestion: 'https://api.example.com:8080/x',
        ),
      ]);
    });

    test('should detect missing slash after port', () {
      expect(AliceUrlValidator.validate('http://192.168.1.1:505api/login'), [
        const AliceUrlIssue(
          AliceUrlIssueType.missingSlashAfterPort,
          suggestion: 'http://192.168.1.1:505/api/login',
        ),
      ]);
    });

    test('should detect missing slash after IP address', () {
      expect(AliceUrlValidator.validate('http://192.168.1.1api/login'), [
        const AliceUrlIssue(
          AliceUrlIssueType.missingSlashAfterHost,
          suggestion: 'http://192.168.1.1/api/login',
        ),
      ]);
    });

    test('should detect missing slash after version', () {
      expect(AliceUrlValidator.validate('https://example.com/v1login?a=1'), [
        const AliceUrlIssue(
          AliceUrlIssueType.missingSlashAfterVersion,
          suggestion: 'https://example.com/v1/login?a=1',
        ),
      ]);
    });

    test('should detect invalid IP address', () {
      expect(types('http://192.168.1/api'), [AliceUrlIssueType.invalidIp]);
      expect(types('http://192.168.1.300/api'), [AliceUrlIssueType.invalidIp]);
    });

    test('should detect double slash, whitespace and missing scheme', () {
      expect(types('https://example.com/api//login'), [
        AliceUrlIssueType.doubleSlash,
      ]);
      expect(types('https://example.com/api/ login'), [
        AliceUrlIssueType.whitespace,
      ]);
      expect(types('192.168.1.1:505/api'), [AliceUrlIssueType.missingScheme]);
    });

    test('should validate call built from server and endpoint', () {
      final call =
          AliceHttpCall(0)
            ..server = '192.168.1.1.505'
            ..endpoint = '/api/login';
      expect(AliceUrlValidator.validateCall(call).map((issue) => issue.type), [
        AliceUrlIssueType.portWithDot,
      ]);
      expect(AliceUrlValidator.validateCall(AliceHttpCall(1)), isEmpty);
    });
  });
}
