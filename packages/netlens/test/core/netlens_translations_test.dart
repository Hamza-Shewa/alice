import 'package:netlens/core/netlens_translations.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:test/test.dart';

void main() {
  group("NetLensTranslations", () {
    test("should return translated value", () {
      expect(
        NetLensTranslations.get(
          languageCode: "en",
          key: NetLensTranslationKey.saveLogId,
        ),
        "Id:",
      );

      expect(
        NetLensTranslations.get(
          languageCode: "en",
          key: NetLensTranslationKey.logsEmpty,
        ),
        "There are no logs to show",
      );
    });

    test(
      "should return english translation when there's no translation found",
      () {
        expect(
          NetLensTranslations.get(
            languageCode: "xx",
            key: NetLensTranslationKey.saveLogId,
          ),
          "Id:",
        );

        expect(
          NetLensTranslations.get(
            languageCode: "xx",
            key: NetLensTranslationKey.logsEmpty,
          ),
          "There are no logs to show",
        );
      },
    );

    test("should return arabic translation", () {
      expect(
        NetLensTranslations.get(
          languageCode: "ar",
          key: NetLensTranslationKey.callDetailsRequest,
        ),
        "الطلب",
      );
    });

    test("should fall back to english for missing key", () {
      expect(
        NetLensTranslations.get(
          languageCode: "xx",
          key: NetLensTranslationKey.netLens,
        ),
        "NetLens",
      );
    });
  });
}
