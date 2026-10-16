import 'package:netlens/core/netlens_logger.dart';
import 'package:netlens/core/netlens_memory_storage.dart';
import 'package:netlens/core/netlens_storage.dart';
import 'package:netlens/model/netlens_redaction.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class NetLensConfiguration with Equatable {
  /// Default max calls count used in default memory storage.
  static const _defaultMaxCalls = 1000;

  /// Default max logs count.
  static const _defaultMaxLogs = 1000;

  /// Should user be notified with notification when there's new request caught
  /// by NetLens. Default value is true.
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors). Default value is true.
  final bool showInspectorOnShake;

  /// Icon url for notification. Default value is '@mipmap/ic_launcher'.
  final String notificationIcon;

  /// Directionality of app. Directionality of the app will be used if set to
  /// null. Default value is null.
  final TextDirection? directionality;

  /// Flag used to show/hide share button
  final bool showShareButton;

  /// Navigator key used to open inspector. Default value is null.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Storage where calls will be saved. The default storage is memory storage.
  final NetLensStorage netLensStorage;

  /// Logger instance.
  final NetLensLogger netLensLogger;

  /// Sensitive values which are masked in shared and exported calls, and
  /// hidden in the inspector until revealed. Default value masks common
  /// credential headers, body fields and query parameters. Use
  /// [NetLensRedaction.none] to turn it off.
  final NetLensRedaction redaction;

  NetLensConfiguration({
    this.showNotification = true,
    this.showInspectorOnShake = true,
    this.notificationIcon = '@mipmap/ic_launcher',
    this.directionality,
    this.showShareButton = true,
    GlobalKey<NavigatorState>? navigatorKey,
    NetLensStorage? storage,
    NetLensLogger? logger,
    this.redaction = const NetLensRedaction(),
  }) : netLensStorage =
           storage ?? NetLensMemoryStorage(maxCallsCount: _defaultMaxCalls),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
       netLensLogger = logger ?? NetLensLogger(maximumSize: _defaultMaxLogs);

  NetLensConfiguration copyWith({
    GlobalKey<NavigatorState>? navigatorKey,
    bool? showNotification,
    bool? showInspectorOnShake,
    String? notificationIcon,
    TextDirection? directionality,
    bool? showShareButton,
    NetLensStorage? netLensStorage,
    NetLensLogger? netLensLogger,
    NetLensRedaction? redaction,
  }) => NetLensConfiguration(
    showNotification: showNotification ?? this.showNotification,
    showInspectorOnShake: showInspectorOnShake ?? this.showInspectorOnShake,
    notificationIcon: notificationIcon ?? this.notificationIcon,
    directionality: directionality ?? this.directionality,
    showShareButton: showShareButton ?? this.showShareButton,
    navigatorKey: navigatorKey ?? this.navigatorKey,
    storage: netLensStorage ?? this.netLensStorage,
    logger: netLensLogger ?? this.netLensLogger,
    redaction: redaction ?? this.redaction,
  );

  @override
  List<Object?> get props => [
    showNotification,
    showInspectorOnShake,
    notificationIcon,
    directionality,
    showShareButton,
    navigatorKey,
    netLensStorage,
    netLensLogger,
    redaction,
  ];
}
