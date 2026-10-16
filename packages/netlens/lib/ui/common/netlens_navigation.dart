import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/ui/call_details/page/netlens_call_details_page.dart';
import 'package:netlens/ui/calls_list/page/netlens_calls_list_page.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:netlens/ui/replay/netlens_replay_page.dart';
import 'package:netlens/ui/stats/netlens_stats_page.dart';
import 'package:netlens/ui/timeline/netlens_timeline_page.dart';
import 'package:netlens/ui/watcher/netlens_watcher_page.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Simple navigation helper class for NetLens.
class NetLensNavigation {
  /// Navigates to calls list page.
  static Future<void> navigateToCallsList({required NetLensCore core}) {
    return _navigateToPage(core: core, child: NetLensCallsListPage(core: core));
  }

  /// Navigates to call details page.
  static Future<void> navigateToCallDetails({
    required NetLensHttpCall call,
    required NetLensCore core,
  }) {
    return _navigateToPage(
      core: core,
      child: NetLensCallDetailsPage(call: call, core: core),
      fade: true,
    );
  }

  /// Navigates to stats page.
  static Future<void> navigateToStats({required NetLensCore core}) {
    return _navigateToPage(
      core: core,
      child: NetLensStatsPage(core),
      fade: true,
    );
  }

  /// Navigates to timeline page.
  static Future<void> navigateToTimeline({required NetLensCore core}) {
    return _navigateToPage(
      core: core,
      child: NetLensTimelinePage(core: core),
      fade: true,
    );
  }

  /// Navigates to page where [call] can be edited and sent again.
  static Future<void> navigateToReplay({
    required NetLensHttpCall call,
    required NetLensCore core,
  }) {
    return _navigateToPage(
      core: core,
      child: NetLensReplayPage(call: call, core: core),
      fade: true,
    );
  }

  /// Navigates to response watcher page.
  static Future<void> navigateToWatcher({required NetLensCore core}) {
    return _navigateToPage(
      core: core,
      child: NetLensWatcherPage(core: core),
      fade: true,
    );
  }

  /// Common helper method which checks whether context is available for
  /// navigation and navigates to a specific page.
  ///
  /// Pages opened from another NetLens page use a [fade], so their app bars
  /// cross-fade in place. The first page slides in over the host app.
  static Future<void> _navigateToPage({
    required NetLensCore core,
    required Widget child,
    bool fade = false,
  }) {
    var context = core.getContext();
    if (context == null) {
      throw StateError("Context is null in NetLensCore.");
    }
    return Navigator.push<void>(
      context,
      NetLensRoute<void>(builder: (_) => child, fade: fade),
    );
  }
}

/// Page route used by all NetLens pages. Transitions are opaque or run over
/// another NetLens page and use NetLens theme on every platform. The default
/// transition of Android fades the new page in over the host app, which lets
/// its page shine through and flashes its background color when it differs
/// from NetLens colors.
///
/// The first page slides in. With [fade] the page fades in over the previous
/// NetLens page without moving. A page which slides would carry its app bar
/// across the screen, while the app bar [Hero] stays in place and shows the
/// old app bar on top of the new page.
class NetLensRoute<T> extends MaterialPageRoute<T> {
  NetLensRoute({required super.builder, this.fade = false});

  final bool fade;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Theme(
      data: NetLensTheme.getTheme(
        brightness: NetLensTheme.resolveBrightness(context),
      ),
      child: Builder(
        builder:
            (BuildContext context) =>
                fade
                    ? FadeTransition(
                      opacity: animation.drive(
                        CurveTween(curve: Curves.easeInOut),
                      ),
                      child: child,
                    )
                    : const CupertinoPageTransitionsBuilder()
                        .buildTransitions<T>(
                          this,
                          context,
                          animation,
                          // No parallax: pages which are opened later
                          // fade in place and the page below stays put.
                          const AlwaysStoppedAnimation<double>(0),
                          child,
                        ),
      ),
    );
  }
}
