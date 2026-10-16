// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show JsonEncoder;
import 'dart:io' show Directory, File, FileMode, IOSink;

import 'package:netlens/core/netlens_utils.dart';
import 'package:netlens/helper/netlens_conversion_helper.dart';
import 'package:netlens/helper/netlens_har_builder.dart';
import 'package:netlens/helper/operating_system.dart';
import 'package:netlens/model/netlens_export_result.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/utils/netlens_parser.dart';
import 'package:netlens/utils/curl.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class NetLensExportHelper {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');
  static const String _fileName = "netlens_log";

  /// Format log based on [call] and tries to share it.
  static Future<NetLensExportResult> shareCall({
    required BuildContext context,
    required NetLensHttpCall call,
  }) async {
    final callLog = await NetLensExportHelper.buildFullCallLog(
      call: call,
      context: context,
    );

    if (callLog == null) {
      return NetLensExportResult(
        success: false,
        error: NetLensExportResultError.logGenerate,
      );
    }

    await SharePlus.instance.share(
      ShareParams(
        text: callLog,
        subject: context.i18n(NetLensTranslationKey.emailSubject),
      ),
    );

    return NetLensExportResult(success: true);
  }

  /// Format log based on [calls] and saves it to file.
  static Future<NetLensExportResult> saveCallsToFile(
    BuildContext context,
    List<NetLensHttpCall> calls,
  ) async {
    final bool permissionStatus = await _getPermissionStatus();
    if (!permissionStatus) {
      final bool status = await _requestPermission();
      if (!status) {
        return NetLensExportResult(
          success: false,
          error: NetLensExportResultError.permission,
        );
      }
    }

    return await _saveToFile(context, calls);
  }

  /// Saves [calls] as a HAR file in the cache directory and opens the system
  /// share sheet with it, so it can be sent to a computer.
  static Future<NetLensExportResult> saveCallsToHarFile(
    List<NetLensHttpCall> calls,
  ) async {
    if (calls.isEmpty) {
      return NetLensExportResult(
        success: false,
        error: NetLensExportResultError.empty,
      );
    }
    final String path;
    try {
      final Directory directory = await getApplicationCacheDirectory();
      path =
          '${directory.path}/${_fileName}_'
          '${DateTime.now().millisecondsSinceEpoch}.har';
      await File(path).writeAsString(NetLensHarBuilder.encode(calls));
    } catch (exception) {
      NetLensUtils.log(exception.toString());
      return NetLensExportResult(
        success: false,
        error: NetLensExportResultError.file,
      );
    }
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path, mimeType: 'application/json')]),
      );
    } catch (exception) {
      // The file is saved, so its path is still useful when sharing fails.
      NetLensUtils.log(exception.toString());
    }
    return NetLensExportResult(success: true, path: path);
  }

  /// Returns current storage permission status. Checks permission for iOS
  /// For other platforms it returns true.
  static Future<bool> _getPermissionStatus() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.status.isGranted;
    } else {
      return true;
    }
  }

  /// Requests permissions for storage for iOS. For other platforms it doesn't
  /// make any action and returns true.
  static Future<bool> _requestPermission() async {
    if (OperatingSystem.isIOS) {
      return Permission.storage.request().isGranted;
    } else {
      return true;
    }
  }

  /// Saves [calls] to file. For android it uses external storage directory and
  /// for ios it uses application documents directory.
  static Future<NetLensExportResult> _saveToFile(
    BuildContext context,
    List<NetLensHttpCall> calls,
  ) async {
    try {
      if (calls.isEmpty) {
        return NetLensExportResult(
          success: false,
          error: NetLensExportResultError.empty,
        );
      }

      final Directory externalDir = await getApplicationCacheDirectory();
      final String fileName =
          '${_fileName}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final File file = File('${externalDir.path}/$fileName')..createSync();
      final IOSink sink = file.openWrite(mode: FileMode.append)
        ..write(await _buildNetLensLog(context: context));
      for (final NetLensHttpCall call in calls) {
        sink.write(buildCallLog(context: context, call: call));
      }
      await sink.flush();
      await sink.close();

      return NetLensExportResult(success: true, path: file.path);
    } catch (exception) {
      NetLensUtils.log(exception.toString());
      return NetLensExportResult(
        success: false,
        error: NetLensExportResultError.file,
      );
    }
  }

  /// Builds log string based on data collected from package info.
  static Future<String> _buildNetLensLog({
    required BuildContext context,
  }) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return '${context.i18n(NetLensTranslationKey.saveHeaderTitle)}\n'
        '${context.i18n(NetLensTranslationKey.saveHeaderAppName)}  ${packageInfo.appName}\n'
        '${context.i18n(NetLensTranslationKey.saveHeaderPackage)} ${packageInfo.packageName}\n'
        '${context.i18n(NetLensTranslationKey.saveHeaderVersion)} ${packageInfo.version}\n'
        '${context.i18n(NetLensTranslationKey.saveHeaderBuildNumber)} ${packageInfo.buildNumber}\n'
        '${context.i18n(NetLensTranslationKey.saveHeaderGenerated)} ${DateTime.now().toIso8601String()}\n'
        '\n';
  }

  /// Builds log string based on [call]: general data, request and response
  /// with headers and bodies, error and curl command.
  static String buildCallLog({
    required BuildContext context,
    required NetLensHttpCall call,
  }) {
    final StringBuffer stringBuffer =
        StringBuffer()..writeAll([
          '===========================================\n',
          '${context.i18n(NetLensTranslationKey.saveLogId)} ${call.id}\n',
          '============================================\n',
          '--------------------------------------------\n',
          '${context.i18n(NetLensTranslationKey.saveLogGeneralData)}\n',
          '--------------------------------------------\n',
          '${context.i18n(NetLensTranslationKey.saveLogServer)} ${call.server} \n',
          '${context.i18n(NetLensTranslationKey.saveLogMethod)} ${call.method} \n',
          '${context.i18n(NetLensTranslationKey.saveLogEndpoint)} ${call.endpoint} \n',
          '${context.i18n(NetLensTranslationKey.saveLogClient)} ${call.client} \n',
          '${context.i18n(NetLensTranslationKey.saveLogDuration)} ${NetLensConversionHelper.formatTime(call.duration)}\n',
          '${context.i18n(NetLensTranslationKey.saveLogSecured)} ${call.secure}\n',
          '${context.i18n(NetLensTranslationKey.saveLogCompleted)} ${!call.loading} \n',
          '--------------------------------------------\n',
          '${context.i18n(NetLensTranslationKey.saveLogRequest)}\n',
          '--------------------------------------------\n',
          '${context.i18n(NetLensTranslationKey.saveLogRequestTime)} ${call.request?.time}\n',
          '${context.i18n(NetLensTranslationKey.saveLogRequestContentType)} ${call.request?.contentType}\n',
          '${context.i18n(NetLensTranslationKey.saveLogRequestCookies)} ${_encoder.convert(call.request?.cookies)}\n',
          '${context.i18n(NetLensTranslationKey.saveLogRequestHeaders)} ${_encoder.convert(call.request?.headers)}\n',
        ]);

    if (call.request?.queryParameters.isNotEmpty ?? false) {
      stringBuffer.write(
        '${context.i18n(NetLensTranslationKey.saveLogRequestQueryParams)} ${_encoder.convert(call.request?.queryParameters)}\n',
      );
    }

    stringBuffer.writeAll([
      '${context.i18n(NetLensTranslationKey.saveLogRequestSize)} ${NetLensConversionHelper.formatBytes(call.request?.size ?? 0)}\n',
      '${context.i18n(NetLensTranslationKey.saveLogRequestBody)} ${NetLensParser.formatBody(context: context, body: call.request?.body, contentType: call.request?.contentType)}\n',
      '--------------------------------------------\n',
      '${context.i18n(NetLensTranslationKey.saveLogResponse)}\n',
      '--------------------------------------------\n',
      '${context.i18n(NetLensTranslationKey.saveLogResponseTime)} ${call.response?.time}\n',
      '${context.i18n(NetLensTranslationKey.saveLogResponseStatus)} ${call.response?.status}\n',
      '${context.i18n(NetLensTranslationKey.saveLogResponseSize)} ${NetLensConversionHelper.formatBytes(call.response?.size ?? 0)}\n',
      '${context.i18n(NetLensTranslationKey.saveLogResponseHeaders)} ${_encoder.convert(call.response?.headers)}\n',
      '${context.i18n(NetLensTranslationKey.saveLogResponseBody)} ${NetLensParser.formatBody(context: context, body: call.response?.body, contentType: NetLensParser.getContentType(context: context, headers: call.response?.headers))}\n',
    ]);

    if (call.error != null) {
      stringBuffer.writeAll([
        '--------------------------------------------\n',
        '${context.i18n(NetLensTranslationKey.saveLogError)}\n',
        '--------------------------------------------\n',
        '${context.i18n(NetLensTranslationKey.saveLogError)}: ${call.error?.error}\n',
      ]);

      if (call.error?.stackTrace != null) {
        stringBuffer.write(
          '${context.i18n(NetLensTranslationKey.saveLogStackTrace)}: ${call.error?.stackTrace}\n',
        );
      }
    }

    stringBuffer.writeAll([
      '--------------------------------------------\n',
      '${context.i18n(NetLensTranslationKey.saveLogCurl)}\n',
      '--------------------------------------------\n',
      Curl.getCurlCommand(call),
      '\n',
      '==============================================\n',
      '\n',
    ]);

    return stringBuffer.toString();
  }

  /// Builds full call log string (package info log and call log).
  static Future<String?> buildFullCallLog({
    required BuildContext context,
    required NetLensHttpCall call,
  }) async {
    try {
      return await _buildNetLensLog(context: context) +
          buildCallLog(call: call, context: context);
    } catch (exception) {
      NetLensUtils.log("Failed to generate call log: $exception");
      return null;
    }
  }
}
