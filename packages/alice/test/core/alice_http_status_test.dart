import 'package:alice/core/alice_http_status.dart';
import 'package:test/test.dart';

void main() {
  group('AliceHttpStatus', () {
    test('should return english info by default', () {
      expect(
        AliceHttpStatus.get(status: 404, languageCode: 'pl')?.name,
        'Not Found',
      );
    });

    test('should return arabic info', () {
      expect(
        AliceHttpStatus.get(status: 404, languageCode: 'ar')?.name,
        'غير موجود',
      );
    });

    test('should return null for unknown code', () {
      expect(AliceHttpStatus.get(status: 299, languageCode: 'en'), isNull);
    });

    test('should return category', () {
      expect(AliceHttpStatus.getCategory(-1), AliceHttpStatusCategory.failed);
      expect(
        AliceHttpStatus.getCategory(101),
        AliceHttpStatusCategory.informational,
      );
      expect(AliceHttpStatus.getCategory(204), AliceHttpStatusCategory.success);
      expect(
        AliceHttpStatus.getCategory(302),
        AliceHttpStatusCategory.redirection,
      );
      expect(
        AliceHttpStatus.getCategory(422),
        AliceHttpStatusCategory.clientError,
      );
      expect(
        AliceHttpStatus.getCategory(503),
        AliceHttpStatusCategory.serverError,
      );
      expect(
        AliceHttpStatus.getCategory(null),
        AliceHttpStatusCategory.unknown,
      );
    });
  });
}
