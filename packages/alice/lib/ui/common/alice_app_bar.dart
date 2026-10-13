import 'package:flutter/material.dart';

/// App bar shared by all Alice pages. It is wrapped in a [Hero] so it stays on
/// screen and morphs into the app bar of the next page instead of being
/// replaced together with the rest of the page.
class AliceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AliceAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.bottom,
  });

  /// Tag shared by app bars of all Alice pages.
  static const String heroTag = 'alice_app_bar';

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      flightShuttleBuilder: _buildShuttle,
      child: AppBar(
        leading: leading,
        title: title,
        actions: actions,
        bottom: bottom,
      ),
    );
  }

  /// Builds widget which is displayed while the app bar is flying between
  /// pages. App bars have different heights (tabs differ) so a plain surface
  /// is used, which can be resized freely without overflowing.
  static Widget _buildShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final ThemeData theme = Theme.of(toHeroContext);
    final Color color =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    return Material(
      color: color,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: theme.appBarTheme.elevation ?? 0,
      child: const SizedBox.expand(),
    );
  }
}
