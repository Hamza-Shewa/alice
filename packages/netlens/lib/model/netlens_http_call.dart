import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:equatable/equatable.dart';

/// Definition of http calls data holder.
// ignore: must_be_immutable
class NetLensHttpCall with Equatable {
  NetLensHttpCall(this.id, {DateTime? createdTime})
    : createdTime = createdTime ?? DateTime.now();

  final int id;
  final DateTime createdTime;
  String client = '';
  bool loading = true;
  bool secure = false;
  String method = '';
  String endpoint = '';
  String server = '';
  String uri = '';
  int duration = 0;

  NetLensHttpRequest? request;
  NetLensHttpResponse? response;
  NetLensHttpError? error;

  @override
  List<Object?> get props => [
    id,
    createdTime,
    client,
    loading,
    secure,
    method,
    endpoint,
    server,
    uri,
    duration,
    request,
    response,
    error,
  ];
}
