import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/ui/common/netlens_language.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Common page widget which is used across NetLens pages.
class NetLensPage extends StatelessWidget {
  const NetLensPage({super.key, required this.core, required this.child});

  final NetLensCore core;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          core.configuration.directionality ?? NetLensLanguage.textDirection,
      child: Theme(
        data: NetLensTheme.getTheme(
          brightness: NetLensTheme.resolveBrightness(context),
        ),
        child: child,
      ),
    );
  }
}
