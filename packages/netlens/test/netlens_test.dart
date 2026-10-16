import 'package:netlens/netlens.dart';
import 'package:netlens/core/netlens_adapter.dart';
import 'package:netlens/core/netlens_logger.dart';
import 'package:netlens/core/netlens_storage.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/mocked_data.dart';

void main() {
  group("NetLens", () {
    late NetLens netLens;
    late NetLensStorage netLensStorage;
    late NetLensLogger netLensLogger;
    setUp(() {
      netLensStorage = NetLensMemoryStorage(maxCallsCount: 1000);
      netLensLogger = NetLensLogger(maximumSize: 1000);
      netLens = NetLens(
        configuration: NetLensConfiguration(
          showInspectorOnShake: false,
          showNotification: false,
          logger: netLensLogger,
          storage: netLensStorage,
        ),
      );
    });

    test("should set new navigator key", () {
      final navigatorKey = GlobalKey<NavigatorState>();

      expect(netLens.getNavigatorKey() != navigatorKey, true);

      netLens.setNavigatorKey(navigatorKey);

      expect(netLens.getNavigatorKey() == navigatorKey, true);
    });

    test("should add log", () {
      final log = NetLensLog(message: "test");

      netLens.addLog(log);

      expect(netLensLogger.logs, [log]);
    });

    test("should add logs", () {
      final logs = [
        NetLensLog(message: "test 1"),
        NetLensLog(message: "test 2"),
      ];

      netLens.addLogs(logs);

      expect(netLensLogger.logs, logs);
    });

    test("should add call", () {
      final call = MockedData.getFilledHttpCall();

      netLens.addHttpCall(call);

      expect(netLensStorage.getCalls(), [call]);
    });

    test("should add adapter", () {
      final call = MockedData.getFilledHttpCall();
      final adapter = FakeAdapter();
      netLens.addAdapter(adapter);

      adapter.addCallLog(call);

      expect(netLensStorage.getCalls(), [call]);
    });

    test("should return is inspector opened flag", () {
      expect(netLens.isInspectorOpened, false);
    });
  });
}

class FakeAdapter with NetLensAdapter {
  void addCallLog(NetLensHttpCall call) {
    netLensCore.addCall(call);
  }
}
