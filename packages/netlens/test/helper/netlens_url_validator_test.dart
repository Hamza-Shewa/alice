import 'package:netlens/helper/netlens_url_validator.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:test/test.dart';

void main() {
  List<NetLensUrlIssueType> types(String url) =>
      NetLensUrlValidator.validate(url).map((issue) => issue.type).toList();

  group('NetLensUrlValidator', () {
    test('should accept valid URLs', () {
      for (final url in [
        'http://192.168.1.1:505/api/login',
        'https://api.example.com/v1/users?page=2',
        'https://api.example.com/v1beta/users',
        'http://localhost:8080/',
        'https://example.com',
        'http://[::1]:8080/api',
      ]) {
        expect(NetLensUrlValidator.validate(url), isEmpty, reason: url);
      }
    });

    test('should detect port written with dot', () {
      expect(NetLensUrlValidator.validate('http://192.168.1.1.505/api/login'), [
        const NetLensUrlIssue(
          NetLensUrlIssueType.portWithDot,
          suggestion: 'http://192.168.1.1:505/api/login',
        ),
      ]);
      expect(NetLensUrlValidator.validate('https://api.example.com.8080/x'), [
        const NetLensUrlIssue(
          NetLensUrlIssueType.portWithDot,
          suggestion: 'https://api.example.com:8080/x',
        ),
      ]);
    });

    test('should detect missing slash after port', () {
      expect(NetLensUrlValidator.validate('http://192.168.1.1:505api/login'), [
        const NetLensUrlIssue(
          NetLensUrlIssueType.missingSlashAfterPort,
          suggestion: 'http://192.168.1.1:505/api/login',
        ),
      ]);
    });

    test('should detect missing slash after IP address', () {
      expect(NetLensUrlValidator.validate('http://192.168.1.1api/login'), [
        const NetLensUrlIssue(
          NetLensUrlIssueType.missingSlashAfterHost,
          suggestion: 'http://192.168.1.1/api/login',
        ),
      ]);
    });

    test('should detect missing slash after version', () {
      expect(NetLensUrlValidator.validate('https://example.com/v1login?a=1'), [
        const NetLensUrlIssue(
          NetLensUrlIssueType.missingSlashAfterVersion,
          suggestion: 'https://example.com/v1/login?a=1',
        ),
      ]);
    });

    test('should accept versions with more digits after the version', () {
      expect(
        NetLensUrlValidator.validate(
          'https://speech.googleapis.com/v1p1beta1/speech:recognize',
        ),
        isEmpty,
      );
      expect(
        NetLensUrlValidator.validate('https://example.com/v2alpha1/users'),
        isEmpty,
      );
    });

    test('should detect invalid IP address', () {
      expect(types('http://192.168.1/api'), [NetLensUrlIssueType.invalidIp]);
      expect(types('http://192.168.1.300/api'), [
        NetLensUrlIssueType.invalidIp,
      ]);
    });

    test('should detect double slash, whitespace and missing scheme', () {
      expect(types('https://example.com/api//login'), [
        NetLensUrlIssueType.doubleSlash,
      ]);
      expect(types('https://example.com/api/ login'), [
        NetLensUrlIssueType.whitespace,
      ]);
      expect(types('192.168.1.1:505/api'), [NetLensUrlIssueType.missingScheme]);
    });

    test('should validate call built from server and endpoint', () {
      final call =
          NetLensHttpCall(0)
            ..server = '192.168.1.1.505'
            ..endpoint = '/api/login';
      expect(
        NetLensUrlValidator.validateCall(call).map((issue) => issue.type),
        [NetLensUrlIssueType.portWithDot],
      );
      expect(NetLensUrlValidator.validateCall(NetLensHttpCall(1)), isEmpty);
    });
  });
}
