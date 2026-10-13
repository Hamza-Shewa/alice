import 'dart:io';

import 'package:alice/helper/alice_export_helper.dart';
import 'package:alice/model/alice_export_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../mock/build_context_mock.dart';
import '../mock/mocked_data.dart';

void main() {
  late BuildContext context;
  setUp(() {
    context = BuildContextMock();
  });

  group("AliceExportHelper", () {
    test("should build correct call log", () async {
      _setPackageInfo();

      final result = await AliceExportHelper.buildFullCallLog(
        context: context,
        call: MockedData.getFilledHttpCall(),
      );
      _verifyLogLines(result!);
    });

    test("should save call log to file", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      _setPackageInfo();
      _setPathProvider();
      _setDefaultTargetPlatform();

      final result = await AliceExportHelper.saveCallsToFile(context, [
        MockedData.getFilledHttpCall(),
      ]);
      expect(result.success, true);
      expect(result.path != null, true);
      expect(result.error, null);

      final file = File(result.path!);
      expect(file.existsSync(), true);
      final content = await file.readAsString();
      _verifyLogLines(content);
      file.delete();
    });
  });

  test("should not save empty call log to file", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setPackageInfo();
    _setPathProvider();
    _setDefaultTargetPlatform();

    final result = await AliceExportHelper.saveCallsToFile(context, []);

    expect(result.success, false);
    expect(result.path, null);
    expect(result.error, AliceExportResultError.empty);
  });

  test("should not save call log to file if file problem occurs", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setPackageInfo();
    _setPathProvider(isFailing: true);
    _setDefaultTargetPlatform();

    final result = await AliceExportHelper.saveCallsToFile(context, [
      MockedData.getFilledHttpCall(),
    ]);

    expect(result.success, false);
    expect(result.path, null);
    expect(result.error, AliceExportResultError.file);
  });

  test("should share call log", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setPackageInfo();
    _setShare();

    final result = await AliceExportHelper.shareCall(
      context: context,
      call: MockedData.getFilledHttpCall(),
    );
    expect(result.success, true);
    expect(result.error, null);
  });
}

void _verifyLogLines(String result) {
  var lines = [
    'Alice - HTTP Inspector',
    'App name:  Alice',
    'Package: pl.hasoft.alice',
    'Alice - HTTP Inspector 1.0',
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
    'Completed:: true ',
    '--------------------------------------------',
    'Request',
    '--------------------------------------------',
    'Request time:',
    'Request content type:: application/json',
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
    '',
  ];
  for (var line in lines) {
    expect(result.contains(line), true);
  }
}

void _setPackageInfo() {
  PackageInfo.setMockInitialValues(
    appName: "Alice",
    packageName: "pl.hasoft.alice",
    version: "1.0",
    buildNumber: "1",
    buildSignature: "buildSignature",
  );
}

void _setPathProvider({bool isFailing = false}) {
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (isFailing) {
          return "";
        } else {
          return ".";
        }
      });
}

void _setDefaultTargetPlatform() {
  debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
}

void _setShare() {
  const MethodChannel channel = MethodChannel(
    'dev.fluttercommunity.plus/share',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return ".";
      });
}
