import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/page/alice_call_details_page.dart';
import 'package:alice/ui/calls_list/page/alice_calls_list_page.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/replay/alice_replay_page.dart';
import 'package:alice/ui/stats/alice_stats_page.dart';
import 'package:alice/ui/watcher/alice_watcher_page.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Simple navigation helper class for Alice.
class AliceNavigation {
  /// Navigates to calls list page.
  static Future<void> navigateToCallsList({required AliceCore core}) {
    return _navigateToPage(core: core, child: AliceCallsListPage(core: core));
  }

  /// Navigates to call details page.
  static Future<void> navigateToCallDetails({
    required AliceHttpCall call,
    required AliceCore core,
  }) {
    return _navigateToPage(
      core: core,
      child: AliceCallDetailsPage(call: call, core: core),
      fade: true,
    );
  }

  /// Navigates to stats page.
  static Future<void> navigateToStats({required AliceCore core}) {
    return _navigateToPage(core: core, child: AliceStatsPage(core), fade: true);
  }

  /// Navigates to page where [call] can be edited and sent again.
  static Future<void> navigateToReplay({
    required AliceHttpCall call,
    required AliceCore core,
  }) {
    return _navigateToPage(
      core: core,
      child: AliceReplayPage(call: call, core: core),
      fade: true,
    );
  }

  /// Navigates to response watcher page.
  static Future<void> navigateToWatcher({required AliceCore core}) {
    return _navigateToPage(
      core: core,
      child: AliceWatcherPage(core: core),
      fade: true,
    );
  }

  /// Common helper method which checks whether context is available for
  /// navigation and navigates to a specific page.
  ///
  /// Pages opened from another Alice page use a [fade], so their app bars
  /// cross-fade in place. The first page slides in over the host app.
  static Future<void> _navigateToPage({
    required AliceCore core,
    required Widget child,
    bool fade = false,
  }) {
    var context = core.getContext();
    if (context == null) {
      throw StateError("Context is null in AliceCore.");
    }
    return Navigator.push<void>(
      context,
      AliceRoute<void>(builder: (_) => child, fade: fade),
    );
  }
}

/// Page route used by all Alice pages. Transitions are opaque or run over
/// another Alice page and use Alice theme on every platform. The default
/// transition of Android fades the new page in over the host app, which lets
/// its page shine through and flashes its background color when it differs
/// from Alice colors.
///
/// The first page slides in. With [fade] the page fades in over the previous
/// Alice page without moving. A page which slides would carry its app bar
/// across the screen, while the app bar [Hero] stays in place and shows the
/// old app bar on top of the new page.
class AliceRoute<T> extends MaterialPageRoute<T> {
  AliceRoute({required super.builder, this.fade = false});

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
      data: AliceTheme.getTheme(
        brightness: AliceTheme.resolveBrightness(context),
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
