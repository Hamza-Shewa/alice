import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/call_details/page/alice_call_details_page.dart';
import 'package:alice/ui/calls_list/page/alice_calls_list_page.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/stats/alice_stats_page.dart';
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
    );
  }

  /// Navigates to stats page.
  static Future<void> navigateToStats({required AliceCore core}) {
    return _navigateToPage(core: core, child: AliceStatsPage(core));
  }

  /// Common helper method which checks whether context is available for
  /// navigation and navigates to a specific page.
  static Future<void> _navigateToPage({
    required AliceCore core,
    required Widget child,
  }) {
    var context = core.getContext();
    if (context == null) {
      throw StateError("Context is null in AliceCore.");
    }
    return Navigator.push<void>(
      context,
      AliceRoute<void>(
        theme: AliceTheme.getTheme(brightness: Theme.of(context).brightness),
        builder: (_) => child,
      ),
    );
  }
}

/// Page route used by all Alice pages. It runs an opaque slide transition
/// with Alice theme on every platform. The default transition of Android fades
/// the new page in, which lets the page of the host app shine through and
/// flashes its background color when it differs from Alice colors.
class AliceRoute<T> extends MaterialPageRoute<T> {
  AliceRoute({required this.theme, required super.builder});

  final ThemeData theme;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Theme(
      data: theme,
      child: Builder(
        builder:
            (BuildContext context) =>
                const CupertinoPageTransitionsBuilder().buildTransitions<T>(
                  this,
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ),
      ),
    );
  }
}
