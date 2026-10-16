import 'dart:async' show FutureOr, StreamSubscription, unawaited;

import 'package:netlens/core/netlens_adapter.dart';
import 'package:netlens/core/netlens_call_replayer.dart';
import 'package:netlens/core/netlens_notification.dart';
import 'package:netlens/core/netlens_storage.dart';
import 'package:netlens/core/netlens_utils.dart';
import 'package:netlens/helper/netlens_call_redactor.dart';
import 'package:netlens/helper/netlens_export_helper.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/helper/operating_system.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_export_result.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens/model/netlens_log.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:netlens/ui/common/netlens_navigation.dart';
import 'package:netlens/utils/shake_detector.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

class NetLensCore {
  /// Configuration of NetLens
  late NetLensConfiguration _configuration;

  /// Detector used to detect device shakes
  ShakeDetector? _shakeDetector;

  /// Helper used for notification management
  NetLensNotification? _notification;

  /// Subscription for call changes
  StreamSubscription<List<NetLensHttpCall>>? _callsSubscription;

  /// Flag used to determine whether is inspector opened
  bool _isInspectorOpened = false;

  /// Adapters which can send calls again.
  final List<NetLensCallReplayer> _replayers = [];

  /// Creates netLens core instance
  NetLensCore({required NetLensConfiguration configuration}) {
    _configuration = configuration;
    _subscribeToCallChanges();
    unawaited(NetLensWatcher.instance.load());
    if (_configuration.showNotification) {
      _notification = NetLensNotification();
      _notification?.configure(
        notificationIcon: _configuration.notificationIcon,
        openInspectorCallback: navigateToCallListScreen,
      );
    }
    if (_configuration.showInspectorOnShake) {
      if (OperatingSystem.isAndroid || OperatingSystem.isIOS) {
        _shakeDetector = ShakeDetector.autoStart(
          onPhoneShake: navigateToCallListScreen,
          shakeThresholdGravity: 4,
        );
      }
    }
  }

  /// Returns current configuration
  NetLensConfiguration get configuration => _configuration;

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _configuration = _configuration.copyWith(navigatorKey: navigatorKey);
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    _shakeDetector?.stopListening();
    _unsubscribeFromCallChanges();
  }

  /// Called when calls has been updated
  Future<void> _onCallsChanged(List<NetLensHttpCall>? calls) async {
    final NetLensNotification? notification = _notification;
    if (notification == null) {
      return;
    }
    if (calls != null && calls.isNotEmpty) {
      final BuildContext? context = getContext();
      if (context == null) {
        return;
      }
      final NetLensStats stats = _configuration.netLensStorage.getStats();
      await notification.showStatsNotification(context: context, stats: stats);
    }
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  Future<void> navigateToCallListScreen() async {
    final BuildContext? context = getContext();
    if (context == null) {
      NetLensUtils.log(
        'Cant start NetLens HTTP Inspector. Please add NavigatorKey to your '
        'application',
      );
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      await NetLensNavigation.navigateToCallsList(core: this);
      _isInspectorOpened = false;
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() =>
      _configuration.navigatorKey?.currentState?.overlay?.context;

  /// Add netLens http call to calls subject
  FutureOr<void> addCall(NetLensHttpCall call) =>
      _configuration.netLensStorage.addCall(call);

  /// Add error to existing netLens http call
  FutureOr<void> addError(NetLensHttpError error, int requestId) =>
      _configuration.netLensStorage.addError(error, requestId);

  /// Add response to existing netLens http call
  FutureOr<void> addResponse(NetLensHttpResponse response, int requestId) =>
      _configuration.netLensStorage.addResponse(response, requestId);

  /// Remove all calls from calls subject
  FutureOr<void> removeCalls() => _configuration.netLensStorage.removeCalls();

  /// Selects call with given [requestId]. It may return null.
  @protected
  NetLensHttpCall? selectCall(int requestId) =>
      _configuration.netLensStorage.selectCall(requestId);

  /// Returns stream which returns list of HTTP calls
  Stream<List<NetLensHttpCall>> get callsStream =>
      _configuration.netLensStorage.callsStream;

  /// Returns all stored HTTP calls.
  List<NetLensHttpCall> getCalls() => _configuration.netLensStorage.getCalls();

  /// Redactor which masks sensitive values as configured.
  NetLensCallRedactor get redactor =>
      NetLensCallRedactor(_configuration.redaction);

  /// Returns all stored calls with sensitive values masked.
  List<NetLensHttpCall> _getRedactedCalls() =>
      getCalls().map(redactor.redact).toList();

  /// Save all calls to file. Sensitive values are masked.
  Future<NetLensExportResult> saveCallsToFile(BuildContext context) =>
      NetLensExportHelper.saveCallsToFile(context, _getRedactedCalls());

  /// Save all calls to a HAR file. Sensitive values are masked.
  Future<NetLensExportResult> saveCallsToHarFile() =>
      NetLensExportHelper.saveCallsToHarFile(_getRedactedCalls());

  /// Injects this core into [adapter]. An adapter which can send calls again
  /// is used to replay calls of its client.
  void addAdapter(NetLensAdapter adapter) {
    adapter.injectCore(this);
    if (adapter is NetLensCallReplayer) {
      _replayers.add(adapter as NetLensCallReplayer);
    }
  }

  /// Returns the adapter which can send [call] again, or null when no added
  /// adapter can.
  NetLensCallReplayer? getReplayer(NetLensHttpCall call) =>
      _replayers.firstWhereOrNull(
        (NetLensCallReplayer replayer) => replayer.canReplay(call),
      );

  /// Returns true when [call] can be sent again.
  bool canReplay(NetLensHttpCall call) => getReplayer(call) != null;

  /// Sends [request], which was built from [call], again with the client which
  /// made [call]. The new call is caught like any other call.
  Future<void> replay(NetLensHttpCall call, NetLensReplayRequest request) {
    final NetLensCallReplayer? replayer = getReplayer(call);
    if (replayer == null) {
      throw StateError('No adapter can replay calls of ${call.client}.');
    }
    return replayer.replay(request);
  }

  /// Adds new log to NetLens logger.
  void addLog(NetLensLog log) => _configuration.netLensLogger.add(log);

  /// Adds list of logs to NetLens logger
  void addLogs(List<NetLensLog> logs) =>
      _configuration.netLensLogger.addAll(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _isInspectorOpened;

  /// Subscribes to storage for call changes.
  void _subscribeToCallChanges() {
    _callsSubscription = _configuration.netLensStorage.callsStream.listen(
      _onCallsChanged,
    );
  }

  /// Unsubscribes storage for call changes.
  void _unsubscribeFromCallChanges() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
  }
}
