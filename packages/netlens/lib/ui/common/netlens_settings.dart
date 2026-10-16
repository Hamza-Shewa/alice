import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Mixin for states of NetLens pages. It rebuilds the page when user selects
/// another language or theme.
mixin NetLensSettingsListenerMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    NetLensLanguage.current.addListener(_onSettingsChanged);
    NetLensTheme.themeMode.addListener(_onSettingsChanged);
    NetLensWatcher.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    NetLensLanguage.current.removeListener(_onSettingsChanged);
    NetLensTheme.themeMode.removeListener(_onSettingsChanged);
    NetLensWatcher.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// App bar button which opens NetLens settings.
class NetLensSettingsButton extends StatelessWidget {
  const NetLensSettingsButton({super.key, required this.core});

  final NetLensCore core;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: context.i18n(NetLensTranslationKey.settings),
      onPressed: () => showNetLensSettings(context, core: core),
    );
  }
}

/// Shows bottom sheet where user can change language and theme of NetLens.
Future<void> showNetLensSettings(
  BuildContext context, {
  required NetLensCore core,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder:
        (BuildContext sheetContext) => ListenableBuilder(
          listenable: Listenable.merge([
            NetLensLanguage.current,
            NetLensTheme.themeMode,
          ]),
          builder:
              (BuildContext context, _) => Directionality(
                textDirection: NetLensLanguage.textDirection,
                child: Theme(
                  data: NetLensTheme.getTheme(
                    brightness: NetLensTheme.resolveBrightness(context),
                  ),
                  // Not const, so the sheet is rebuilt when a setting changes.
                  child: _NetLensSettingsSheet(core: core),
                ),
              ),
        ),
  );
}

class _NetLensSettingsSheet extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _NetLensSettingsSheet({required this.core});

  final NetLensCore core;

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
                context.i18n(NetLensTranslationKey.settings),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _SettingTitle(
                icon: Icons.translate,
                title: context.i18n(NetLensTranslationKey.language),
              ),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  for (final NetLensLanguageOption option
                      in NetLensLanguage.supported)
                    ButtonSegment<String>(
                      value: option.code,
                      label: Text(option.name),
                    ),
                ],
                selected: {NetLensLanguage.current.value},
                onSelectionChanged:
                    (Set<String> value) =>
                        NetLensLanguage.current.value = value.first,
              ),
              const SizedBox(height: 20),
              _SettingTitle(
                icon: Icons.palette_outlined,
                title: context.i18n(NetLensTranslationKey.theme),
              ),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(
                      context.i18n(NetLensTranslationKey.themeSystem),
                    ),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(context.i18n(NetLensTranslationKey.themeLight)),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(context.i18n(NetLensTranslationKey.themeDark)),
                  ),
                ],
                selected: {NetLensTheme.themeMode.value},
                onSelectionChanged:
                    (Set<ThemeMode> value) =>
                        NetLensTheme.themeMode.value = value.first,
              ),
              const SizedBox(height: 20),
              _WatcherTile(core: core),
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

/// Opens the response watcher page.
class _WatcherTile extends StatelessWidget {
  const _WatcherTile({required this.core});

  final NetLensCore core;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pop();
          NetLensNavigation.navigateToWatcher(core: core);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.i18n(NetLensTranslationKey.watcher),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.i18n(NetLensTranslationKey.watcherSubtitle),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
