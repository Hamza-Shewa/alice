import 'package:flutter/material.dart';

/// App bar shared by all NetLens pages. It is wrapped in a [Hero] so it stays on
/// screen and morphs into the app bar of the next page instead of being
/// replaced together with the rest of the page.
class NetLensAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NetLensAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.bottom,
  });

  /// Tag shared by app bars of all NetLens pages.
  static const String heroTag = 'netlens_app_bar';

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
        // Explicit, because the bar is also built outside of its route while
        // it flies between pages.
        leading:
            leading ?? (Navigator.canPop(context) ? const BackButton() : null),
        automaticallyImplyLeading: false,
        title: title,
        actions: actions,
        bottom: bottom,
      ),
    );
  }

  /// Builds widget which is displayed while the app bar is flying between
  /// pages. It cross-fades the app bar of the source page into the app bar of
  /// the destination page, so the content never disappears during the flight.
  /// Each bar is laid out with its own height and clipped, because heights of
  /// the bars differ (tabs differ) and a resized bar would overflow.
  static Widget _buildShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final ThemeData toTheme = Theme.of(toHeroContext);
    final Animation<double> fadeOut = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    ).drive(Tween<double>(begin: 1, end: 0));
    final Animation<double> fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1, curve: Curves.easeIn),
    );

    return Material(
      // Opaque base, so the page below never shines through the fading bars.
      color: toTheme.appBarTheme.backgroundColor ?? toTheme.colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(opacity: fadeOut, child: _buildBar(fromHeroContext)),
          FadeTransition(opacity: fadeIn, child: _buildBar(toHeroContext)),
        ],
      ),
    );
  }

  /// Builds the app bar of [heroContext] outside of its page.
  static Widget _buildBar(BuildContext heroContext) {
    final Hero hero = heroContext.widget as Hero;
    final AppBar appBar = hero.child as AppBar;
    // Same height which Scaffold gives to the app bar.
    final double height =
        appBar.preferredSize.height + MediaQuery.paddingOf(heroContext).top;
    return Theme(
      data: Theme.of(heroContext),
      child: Directionality(
        textDirection: Directionality.of(heroContext),
        child: ClipRect(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return OverflowBox(
                alignment: AlignmentDirectional.topStart,
                minWidth: constraints.maxWidth,
                maxWidth: constraints.maxWidth,
                minHeight: height,
                maxHeight: height,
                child: hero.child,
              );
            },
          ),
        ),
      ),
    );
  }
}
