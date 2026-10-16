import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:equatable/equatable.dart';

/// Definition of http calls data holder.
// ignore: must_be_immutable
class AliceHttpCall with Equatable {
  AliceHttpCall(this.id, {DateTime? createdTime})
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

  AliceHttpRequest? request;
  AliceHttpResponse? response;
  AliceHttpError? error;

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
