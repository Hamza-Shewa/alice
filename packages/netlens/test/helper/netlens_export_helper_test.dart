import 'dart:io';

import 'package:netlens/helper/netlens_export_helper.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../mock/build_context_mock.dart';
import '../mock/mocked_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final BuildContext buildContext = BuildContextMock();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'NetLens',
      packageName: 'pl.hasoft.netLens',
      version: '1.0',
      buildNumber: '1',
      buildSignature: 'signature',
    );
  });

  group("NetLensExportHelper", () {
    test("should build full call log", () async {
      final NetLensHttpCall call = MockedData.getFilledHttpCall();
      final String? result = await NetLensExportHelper.buildFullCallLog(
        context: buildContext,
        call: call,
      );

      expect(result, isNotNull);
      _verifyLogLines(result!);
    });

    test("should save calls to file", () async {
      // Save to a temporary folder, so the test leaves no files behind.
      final Directory directory = Directory.systemTemp.createTempSync(
        'netlens_export_test',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
              return directory.path;
            },
          );

      final NetLensHttpCall call = MockedData.getFilledHttpCall();
      final result = await NetLensExportHelper.saveCallsToFile(buildContext, [
        call,
      ]);

      expect(result.success, true);
      expect(result.path, isNotEmpty);
    });

    test("should not save empty calls to file", () async {
      final result = await NetLensExportHelper.saveCallsToFile(
        buildContext,
        [],
      );
      expect(result.success, false);
    });

    test("should share call", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/share'),
            (MethodCall methodCall) async {
              return null;
            },
          );

      final NetLensHttpCall call = MockedData.getFilledHttpCall();
      final result = await NetLensExportHelper.shareCall(
        context: buildContext,
        call: call,
      );

      expect(result.success, true);
    });
  });
}

void _verifyLogLines(String result) {
  var lines = [
    'NetLens - HTTP Inspector',
    'App name:  NetLens',
    'Package: pl.hasoft.netLens',
    'Version: 1.0',
    'Build number: 1',
    'Generated:',
    '',
    '===========================================',
    'Id:',
    '============================================',
    '--------------------------------------------',
    'General data',
    '--------------------------------------------',
    'Server: https://test.com ',
    'Method: POST ',
    'Endpoint: /test ',
    'Client:  ',
    'Duration: 0 ms',
    'Secured connection: true',
    'Completed: true ',
    '--------------------------------------------',
    'Request',
    '--------------------------------------------',
    'Request time:',
    'Request content type: application/json',
    'Request cookies: []',
    'Request headers: {}',
    'Request size: 0 B',
    'Request body: {',
    '  "id": 0',
    '}',
    '--------------------------------------------',
    'Response',
    '--------------------------------------------',
    'Response time:',
    'Response status: 0',
    'Response size: 0 B',
    'Response headers: {}',
    'Response body: {"id": 0}',
    '--------------------------------------------',
    'Curl',
    '--------------------------------------------',
    'curl -X POST ',
    '==============================================',
  ];

  final split = result.split("\n");
  for (var index = 0; index < lines.length; index++) {
    expect(split[index].contains(lines[index]), true);
  }
}
