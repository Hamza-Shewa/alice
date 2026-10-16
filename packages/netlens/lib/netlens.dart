import 'package:netlens/core/netlens_adapter.dart';
import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

export 'package:netlens/core/netlens_call_replayer.dart';
export 'package:netlens/model/netlens_log.dart';
export 'package:netlens/model/netlens_redaction.dart';
export 'package:netlens/model/netlens_replay_request.dart';
export 'package:netlens/core/netlens_memory_storage.dart';
export 'package:netlens/utils/netlens_parser.dart';

class NetLens {
  /// NetLens core instance
  late final NetLensCore _netLensCore;

  /// Creates netLens instance.
  NetLens({NetLensConfiguration? configuration}) {
    _netLensCore = NetLensCore(
      configuration: configuration ?? NetLensConfiguration(),
    );
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _netLensCore.setNavigatorKey(navigatorKey);
  }

  /// Get currently used navigation key
  GlobalKey<NavigatorState>? getNavigatorKey() =>
      _netLensCore.configuration.navigatorKey;

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector() => _netLensCore.navigateToCallListScreen();

  /// Handle generic http call. Can be used to any http client.
  void addHttpCall(NetLensHttpCall netLensHttpCall) {
    assert(netLensHttpCall.request != null, "Http call request can't be null");
    assert(
      netLensHttpCall.response != null,
      "Http call response can't be null",
    );

    _netLensCore.addCall(netLensHttpCall);
  }

  /// Adds new log to NetLens logger.
  void addLog(NetLensLog log) => _netLensCore.addLog(log);

  /// Adds list of logs to NetLens logger
  void addLogs(List<NetLensLog> logs) => _netLensCore.addLogs(logs);

  /// Returns flag which determines whether inspector is opened
  bool get isInspectorOpened => _netLensCore.isInspectorOpened;

  /// Adds new adapter to NetLens.
  void addAdapter(NetLensAdapter adapter) => _netLensCore.addAdapter(adapter);
}
