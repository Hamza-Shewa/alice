import 'package:flutter/material.dart';

/// Language which can be selected in NetLens UI.
class NetLensLanguageOption {
  const NetLensLanguageOption({
    required this.code,
    required this.name,
    this.isRtl = false,
  });

  /// Language code, for example "en".
  final String code;

  /// Name of the language written in that language.
  final String name;

  /// Whether the language is written from right to left.
  final bool isRtl;
}

/// Holds language used by NetLens UI. It is independent of the locale of the
/// host app and it is English until user changes it.
class NetLensLanguage {
  static const String defaultCode = 'en';

  static const List<NetLensLanguageOption> supported = [
    NetLensLanguageOption(code: 'en', name: 'English'),
    NetLensLanguageOption(code: 'ar', name: 'العربية', isRtl: true),
  ];

  /// Currently selected language code.
  static final ValueNotifier<String> current = ValueNotifier(defaultCode);

  /// Text direction of the currently selected language.
  static TextDirection get textDirection =>
      supported.any((option) => option.code == current.value && option.isRtl)
          ? TextDirection.rtl
          : TextDirection.ltr;
}
