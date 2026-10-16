/// Model of export result.
class NetLensExportResult {
  final bool success;
  final NetLensExportResultError? error;
  final String? path;

  NetLensExportResult({required this.success, this.error, this.path});
}

/// Definition of all possible export errors.
enum NetLensExportResultError { logGenerate, empty, permission, file }
