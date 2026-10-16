import 'package:netlens/core/netlens_logger.dart';
import 'package:netlens/model/netlens_log.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late NetLensLogger netLensLogger;
  setUp(() {
    netLensLogger = NetLensLogger(maximumSize: 1000);
  });

  group("NetLensLogger", () {
    test("should add log", () {
      final log = NetLensLog(message: "test");

      netLensLogger.add(log);

      expect(netLensLogger.logs, [log]);
    });

    test("should add logs", () {
      final logs = [NetLensLog(message: "test"), NetLensLog(message: "test2")];

      netLensLogger.addAll(logs);

      expect(netLensLogger.logs, logs);
    });

    test("should clear logs", () {
      final logs = [NetLensLog(message: "test"), NetLensLog(message: "test2")];

      netLensLogger.addAll(logs);

      expect(netLensLogger.logs.isNotEmpty, true);

      netLensLogger.clearLogs();

      expect(netLensLogger.logs.isEmpty, true);
    });
  });
}
