import 'package:netlens/core/netlens_storage.dart';
import 'package:netlens/core/netlens_utils.dart';
import 'package:netlens/helper/operating_system.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Helper for displaying local notifications.
class NetLensNotification {
  static const String _payload = 'NetLens';
  static const String _channel = 'NetLens';
  static const String _callCount = '[callCount]';

  /// Notification plugin instance
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  /// Notification configuration for NetLens.
  late final NotificationDetails _notificationDetails;

  /// Callback used to open inspector on notification click.
  late final void Function() _openInspectorCallback;

  /// Currently displayed notification message
  String? _notificationMessageDisplayed;

  /// Is current notification being processed
  bool _isNotificationProcessing = false;

  /// Configures local notifications with [notificationIcon] and
  /// [openInspectorCallback].
  void configure({
    required String notificationIcon,
    required void Function() openInspectorCallback,
  }) {
    _openInspectorCallback = openInspectorCallback;
    _notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel,
        _channel,
        channelDescription: _channel,
        enableVibration: false,
        playSound: false,
        largeIcon: DrawableResourceAndroidBitmap(notificationIcon),
      ),
      iOS: const DarwinNotificationDetails(presentSound: false),
    );

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(notificationIcon);
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsMacOS,
        );
    _flutterLocalNotificationsPlugin?.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    _requestNotificationPermissions();
  }

  /// Requests notification permissions to display stats notification.
  Future<void> _requestNotificationPermissions() async {
    if (OperatingSystem.isIOS || OperatingSystem.isMacOS) {
      await _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _flutterLocalNotificationsPlugin
          ?.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (OperatingSystem.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              ?.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// Called when notification has been clicked. It navigates to calls screen.
  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    _openInspectorCallback();
  }

  /// Formats [stats] for notification message.
  String _getNotificationMessage({
    required BuildContext context,
    required NetLensStats stats,
  }) => <String>[
    if (stats.loading > 0)
      '${context.i18n(NetLensTranslationKey.notificationLoading)} ${stats.loading}',
    if (stats.successes > 0)
      '${context.i18n(NetLensTranslationKey.notificationSuccess)} ${stats.successes}',
    if (stats.redirects > 0)
      '${context.i18n(NetLensTranslationKey.notificationRedirect)} ${stats.redirects}',
    if (stats.errors > 0)
      '${context.i18n(NetLensTranslationKey.notificationError)} ${stats.errors}',
  ].join(' | ');

  /// Shows current stats notification. It formats [stats] into simple
  /// notification which is displayed when stats has changed.
  Future<void> showStatsNotification({
    required BuildContext context,
    required NetLensStats stats,
  }) async {
    try {
      if (_isNotificationProcessing) {
        return;
      }
      final message = _getNotificationMessage(context: context, stats: stats);
      if (message == _notificationMessageDisplayed) {
        return;
      }

      _isNotificationProcessing = true;

      await _flutterLocalNotificationsPlugin?.show(
        0,
        context
            .i18n(NetLensTranslationKey.notificationTotalRequests)
            .replaceAll(_callCount, stats.total.toString()),
        message,
        _notificationDetails,
        payload: _payload,
      );

      _notificationMessageDisplayed = message;
    } catch (error) {
      NetLensUtils.log(error.toString());
    } finally {
      _isNotificationProcessing = false;
    }
  }
}
