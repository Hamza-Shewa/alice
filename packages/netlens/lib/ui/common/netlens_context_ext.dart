import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/core/netlens_translations.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:flutter/material.dart';

/// Extension for [BuildContext].
extension NetLensContextExt on BuildContext {
  /// Translates given key to the language selected in NetLens, which is English
  /// by default. If it fails to translate [key], it will return [key] itself.
  String i18n(NetLensTranslationKey key) {
    try {
      return NetLensTranslations.get(
        languageCode: NetLensLanguage.current.value,
        key: key,
      );
    } catch (error) {
      return key.toString();
    }
  }
}
