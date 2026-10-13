import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:flutter/material.dart';

/// Language which can be selected in Alice UI.
class AliceLanguageOption {
  const AliceLanguageOption({
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

/// Holds language used by Alice UI. It is independent of the locale of the
/// host app and it is English until user changes it.
class AliceLanguage {
  static const String defaultCode = 'en';

  static const List<AliceLanguageOption> supported = [
    AliceLanguageOption(code: 'en', name: 'English'),
    AliceLanguageOption(code: 'ar', name: 'العربية', isRtl: true),
    AliceLanguageOption(code: 'pl', name: 'Polski'),
  ];

  /// Currently selected language code.
  static final ValueNotifier<String> current = ValueNotifier(defaultCode);

  /// Text direction of the currently selected language.
  static TextDirection get textDirection =>
      supported.any((option) => option.code == current.value && option.isRtl)
          ? TextDirection.rtl
          : TextDirection.ltr;
}

/// Mixin for states of Alice pages. It rebuilds the page when user selects
/// another language.
mixin AliceLanguageListenerMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    AliceLanguage.current.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AliceLanguage.current.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// App bar button which opens a menu to change the language of Alice.
class AliceLanguageButton extends StatelessWidget {
  const AliceLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate),
      tooltip: context.i18n(AliceTranslationKey.language),
      initialValue: AliceLanguage.current.value,
      onSelected: (String code) => AliceLanguage.current.value = code,
      itemBuilder:
          (BuildContext context) => [
            for (final AliceLanguageOption option in AliceLanguage.supported)
              CheckedPopupMenuItem<String>(
                value: option.code,
                checked: option.code == AliceLanguage.current.value,
                child: Text(option.name),
              ),
          ],
    );
  }
}
