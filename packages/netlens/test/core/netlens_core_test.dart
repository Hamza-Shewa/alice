import 'package:netlens/netlens.dart';
import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/core/netlens_logger.dart';
import 'package:netlens/core/netlens_storage.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mock/netlens_logger_mock.dart';
import '../mock/netlens_storage_mock.dart';
import '../mock/mocked_data.dart';

void main() {
  late NetLensCore netLensCore;
  late NetLensStorage netLensStorage;
  late NetLensLogger netLensLogger;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(MockedData.getLoadingHttpCall());
    registerFallbackValue(NetLensHttpError());
    registerFallbackValue(NetLensHttpResponse());
    registerFallbackValue(NetLensLog(message: ""));
    netLensStorage = NetLensStorageMock();
    netLensLogger = NetLensLoggerMock();

    when(
      () => netLensStorage.callsStream,
    ).thenAnswer((_) => const Stream.empty());
    netLensCore = NetLensCore(
      configuration: NetLensConfiguration(
        showNotification: false,
        showInspectorOnShake: false,
        storage: netLensStorage,
        logger: netLensLogger,
      ),
    );
  });

  group("NetLensCore", () {
    test("should use storage to add call", () {
      when(() => netLensStorage.addCall(any())).thenAnswer((_) => () {});

      netLensCore.addCall(MockedData.getLoadingHttpCall());

      verify(() => netLensStorage.addCall(any()));
    });

    test("should use storage to add error", () {
      when(
        () => netLensStorage.addError(any(), any()),
      ).thenAnswer((_) => () {});

      netLensCore.addError(NetLensHttpError(), 0);

      verify(() => netLensStorage.addError(any(), any()));
    });

    test("should use storage to add response", () {
      when(
        () => netLensStorage.addResponse(any(), any()),
      ).thenAnswer((_) => () {});

      netLensCore.addResponse(NetLensHttpResponse(), 0);

      verify(() => netLensStorage.addResponse(any(), any()));
    });

    test("should use storage to remove calls", () {
      when(() => netLensStorage.removeCalls()).thenAnswer((_) => () {});

      netLensCore.removeCalls();

      verify(() => netLensStorage.removeCalls());
    });

    test("should use storage to get calls stream", () async {
      final calls = [MockedData.getLoadingHttpCall()];
      when(
        () => netLensStorage.callsStream,
      ).thenAnswer((_) => Stream.value(calls));

      expect(await netLensCore.callsStream.first, calls);

      verify(() => netLensStorage.callsStream);
    });

    test("should use storage to get calls", () {
      final calls = [MockedData.getLoadingHttpCall()];
      when(() => netLensStorage.getCalls()).thenAnswer((_) => calls);

      expect(netLensCore.getCalls(), calls);

      verify(() => netLensStorage.getCalls());
    });

    test("should use logger to add log", () {
      when(() => netLensLogger.add(any())).thenAnswer((_) => {});

      netLensCore.addLog(NetLensLog(message: "test"));

      verify(() => netLensCore.addLog(any()));
    });

    test("should use logger to add logs", () {
      when(() => netLensLogger.addAll(any())).thenAnswer((_) => {});

      netLensCore.addLogs([NetLensLog(message: "test")]);

      verify(() => netLensCore.addLogs(any()));
    });
  });
}
