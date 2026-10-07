import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// All definitions for theming Alice.
class AliceTheme {
  static const Color red = Color(0xffff3f34);
  static const Color lightRed = Color(0xffff5e57);
  static const Color green = Color(0xff05c46b);
  static const Color grey = Color(0xff808e9b);
  static const Color orange = Color(0xffffa801);
  static const Color white = Color(0xffffffff);

  // Darker variants used on light backgrounds so status text keeps a
  // readable contrast ratio.
  static const Color darkRed = Color(0xffc62828);
  static const Color darkGreen = Color(0xff00804a);
  static const Color darkOrange = Color(0xffa85c00);

  /// Returns general theme data.
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AliceTheme._getColorScheme(),
      dividerColor: Colors.transparent,
      buttonTheme: const ButtonThemeData(
        buttonColor: lightRed,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  /// Checks whether is dark mode enabled.
  static bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  /// Returns color scheme based on dark mode.
  static ColorScheme _getColorScheme() =>
      _isDarkMode
          ? const ColorScheme.dark(primary: AliceTheme.lightRed)
          : const ColorScheme.light(primary: AliceTheme.lightRed);

  /// Returns color which represents HTTP [status]. Brighter colors are used in
  /// dark mode and darker ones in light mode to keep text readable.
  static Color getStatusColor(BuildContext context, int? status) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color neutral = Theme.of(context).colorScheme.onSurfaceVariant;
    return switch (status) {
      -1 => isDark ? red : darkRed,
      int status when status >= 200 && status < 300 =>
        isDark ? green : darkGreen,
      int status when status >= 300 && status < 400 =>
        isDark ? orange : darkOrange,
      int status when status >= 400 && status < 600 => isDark ? red : darkRed,
      _ => neutral,
    };
  }

  /// Return log text color based on diagnostic [level].
  static Color getLogTextColor(BuildContext context, DiagnosticLevel level) =>
      switch (level) {
        DiagnosticLevel.hidden => Colors.grey,
        DiagnosticLevel.fine => Colors.grey,
        DiagnosticLevel.debug => Theme.of(context).colorScheme.onSurface,
        DiagnosticLevel.info => Theme.of(context).colorScheme.onSurface,
        DiagnosticLevel.warning => Colors.orange,
        DiagnosticLevel.hint => Colors.grey,
        DiagnosticLevel.summary => Theme.of(context).colorScheme.onSurface,
        DiagnosticLevel.error => Theme.of(context).colorScheme.error,
        DiagnosticLevel.off => Colors.purple,
      };
}
