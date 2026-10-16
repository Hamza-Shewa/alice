import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:json_annotation/json_annotation.dart';

/// Convert [NetLensFormDataField] to and from JSON.
class NetLensFormDataFieldConverter
    implements JsonConverter<NetLensFormDataField, Map<String, dynamic>> {
  const NetLensFormDataFieldConverter();

  /// Instance of [NetLensFormDataFieldConverter].
  static const NetLensFormDataFieldConverter instance =
      NetLensFormDataFieldConverter();

  @override
  NetLensFormDataField fromJson(Map<String, dynamic> json) =>
      NetLensFormDataField(json['name'] as String, json['value'] as String);

  @override
  Map<String, dynamic> toJson(NetLensFormDataField object) => <String, dynamic>{
    'name': object.name,
    'value': object.value,
  };
}
