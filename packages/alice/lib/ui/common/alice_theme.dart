import 'package:alice/helper/alice_issue_analyzer.dart';
import 'package:alice/helper/alice_log_classifier.dart';
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

  /// Theme mode selected by user. System follows the host app.
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.system,
  );

  /// Returns brightness which Alice should use. Unless user selected light or
  /// dark mode it follows the theme of the host app found at [hostContext].
  static Brightness resolveBrightness(BuildContext hostContext) =>
      switch (themeMode.value) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system => Theme.of(hostContext).brightness,
      };

  static final ThemeData _lightTheme = _buildTheme(Brightness.light);
  static final ThemeData _darkTheme = _buildTheme(Brightness.dark);

  /// Returns general theme data. Themes are created once so rebuilding a page
  /// doesn't swap the theme instance. When [brightness] is null, the platform
  /// brightness is used.
  static ThemeData getTheme({Brightness? brightness}) =>
      (brightness ?? _platformBrightness) == Brightness.dark
          ? _darkTheme
          : _lightTheme;

  static ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          brightness == Brightness.dark
              ? const ColorScheme.dark(primary: AliceTheme.lightRed)
              : const ColorScheme.light(primary: AliceTheme.lightRed),
      dividerColor: Colors.transparent,
      buttonTheme: const ButtonThemeData(
        buttonColor: lightRed,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  /// Returns brightness of the platform.
  static Brightness get _platformBrightness =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

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

  /// Returns color which marks the side responsible for a failed call.
  static Color getIssueColor(BuildContext context, AliceIssueOrigin origin) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (origin) {
      AliceIssueOrigin.frontend =>
        isDark ? const Color(0xff4dd0e1) : const Color(0xff00838f),
      AliceIssueOrigin.backend =>
        isDark ? const Color(0xffce93d8) : const Color(0xff8e24aa),
      AliceIssueOrigin.network =>
        isDark ? const Color(0xff90a4ae) : const Color(0xff546e7a),
    };
  }

  /// Returns color of a log entry detected as [info].
  static Color getLogKindColor(BuildContext context, AliceLogInfo info) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (info.kind) {
      AliceLogKind.request =>
        isDark ? const Color(0xff64b5f6) : const Color(0xff1565c0),
      AliceLogKind.response => getStatusColor(context, info.status ?? 200),
      AliceLogKind.error => isDark ? red : darkRed,
      AliceLogKind.warning => isDark ? orange : darkOrange,
      AliceLogKind.info => Theme.of(context).colorScheme.onSurfaceVariant,
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
