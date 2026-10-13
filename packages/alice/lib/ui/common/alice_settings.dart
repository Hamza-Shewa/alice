import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_language.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:flutter/material.dart';

/// Mixin for states of Alice pages. It rebuilds the page when user selects
/// another language or theme.
mixin AliceSettingsListenerMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    AliceLanguage.current.addListener(_onSettingsChanged);
    AliceTheme.themeMode.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AliceLanguage.current.removeListener(_onSettingsChanged);
    AliceTheme.themeMode.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// App bar button which opens Alice settings.
class AliceSettingsButton extends StatelessWidget {
  const AliceSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: context.i18n(AliceTranslationKey.settings),
      onPressed: () => showAliceSettings(context),
    );
  }
}

/// Shows bottom sheet where user can change language and theme of Alice.
Future<void> showAliceSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder:
        (BuildContext sheetContext) => ListenableBuilder(
          listenable: Listenable.merge([
            AliceLanguage.current,
            AliceTheme.themeMode,
          ]),
          builder:
              (BuildContext context, _) => Directionality(
                textDirection: AliceLanguage.textDirection,
                child: Theme(
                  data: AliceTheme.getTheme(
                    brightness: AliceTheme.resolveBrightness(context),
                  ),
                  // Not const, so the sheet is rebuilt when a setting changes.
                  child: _AliceSettingsSheet(),
                ),
              ),
        ),
  );
}

class _AliceSettingsSheet extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _AliceSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.i18n(AliceTranslationKey.settings),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _SettingTitle(
                icon: Icons.translate,
                title: context.i18n(AliceTranslationKey.language),
              ),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  for (final AliceLanguageOption option
                      in AliceLanguage.supported)
                    ButtonSegment<String>(
                      value: option.code,
                      label: Text(option.name),
                    ),
                ],
                selected: {AliceLanguage.current.value},
                onSelectionChanged:
                    (Set<String> value) =>
                        AliceLanguage.current.value = value.first,
              ),
              const SizedBox(height: 20),
              _SettingTitle(
                icon: Icons.palette_outlined,
                title: context.i18n(AliceTranslationKey.theme),
              ),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(context.i18n(AliceTranslationKey.themeSystem)),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(context.i18n(AliceTranslationKey.themeLight)),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(context.i18n(AliceTranslationKey.themeDark)),
                  ),
                ],
                selected: {AliceTheme.themeMode.value},
                onSelectionChanged:
                    (Set<ThemeMode> value) =>
                        AliceTheme.themeMode.value = value.first,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
