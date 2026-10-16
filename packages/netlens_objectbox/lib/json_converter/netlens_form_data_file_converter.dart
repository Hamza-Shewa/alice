import 'package:netlens/model/netlens_form_data_file.dart';
import 'package:json_annotation/json_annotation.dart';

/// Convert [NetLensFormDataFile] to and from JSON.
class NetLensFormDataFileConverter
    implements JsonConverter<NetLensFormDataFile, Map<String, dynamic>> {
  const NetLensFormDataFileConverter();

  /// Instance of [NetLensFormDataFileConverter].
  static const NetLensFormDataFileConverter instance =
      NetLensFormDataFileConverter();

  @override
  NetLensFormDataFile fromJson(Map<String, dynamic> json) =>
      NetLensFormDataFile(
        json['fileName'] as String?,
        json['contentType'] as String,
        (json['length'] as num).toInt(),
      );

  @override
  Map<String, dynamic> toJson(NetLensFormDataFile object) => <String, dynamic>{
    'fileName': object.fileName,
    'contentType': object.contentType,
    'length': object.length,
  };
}
