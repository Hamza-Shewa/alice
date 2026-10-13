import 'package:alice/model/alice_translation.dart';
import 'package:alice/core/alice_translations.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:flutter/material.dart';

/// Extension for [BuildContext].
extension AliceContextExt on BuildContext {
  /// Translates given key to the language selected in Alice, which is English
  /// by default. If it fails to translate [key], it will return [key] itself.
  String i18n(AliceTranslationKey key) {
    try {
      return AliceTranslations.get(
        languageCode: AliceLanguage.current.value,
        key: key,
      );
    } catch (error) {
      return key.toString();
    }
  }
}
