import 'package:netlens/core/netlens_http_status.dart';
import 'package:test/test.dart';

void main() {
  group('NetLensHttpStatus', () {
    test('should return english info by default', () {
      expect(
        NetLensHttpStatus.get(status: 404, languageCode: 'xx')?.name,
        'Not Found',
      );
    });

    test('should return arabic info', () {
      expect(
        NetLensHttpStatus.get(status: 404, languageCode: 'ar')?.name,
        'غير موجود',
      );
    });

    test('should return null for unknown code', () {
      expect(NetLensHttpStatus.get(status: 299, languageCode: 'en'), isNull);
    });

    test('should return category', () {
      expect(
        NetLensHttpStatus.getCategory(-1),
        NetLensHttpStatusCategory.failed,
      );
      expect(
        NetLensHttpStatus.getCategory(101),
        NetLensHttpStatusCategory.informational,
      );
      expect(
        NetLensHttpStatus.getCategory(204),
        NetLensHttpStatusCategory.success,
      );
      expect(
        NetLensHttpStatus.getCategory(302),
        NetLensHttpStatusCategory.redirection,
      );
      expect(
        NetLensHttpStatus.getCategory(422),
        NetLensHttpStatusCategory.clientError,
      );
      expect(
        NetLensHttpStatus.getCategory(503),
        NetLensHttpStatusCategory.serverError,
      );
      expect(
        NetLensHttpStatus.getCategory(null),
        NetLensHttpStatusCategory.unknown,
      );
    });
  });
}
