// ignore_for_file: must_be_immutable

import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:netlens_objectbox/extensions/netlens_http_error_extension.dart';
import 'package:netlens_objectbox/extensions/netlens_http_request_extension.dart';
import 'package:netlens_objectbox/extensions/netlens_http_response_extension.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_error.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_request.dart';
import 'package:netlens_objectbox/model/cached_netlens_http_response.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

/// ObjectBox [Entity] of [NetLensHttpCall].
@Entity()
class CachedNetLensHttpCall implements NetLensHttpCall {
  CachedNetLensHttpCall(
    this.id, {
    this.objectId = 0,
    DateTime? createdTime,
    this.client = '',
    this.loading = true,
    this.secure = false,
    this.method = '',
    this.endpoint = '',
    this.server = '',
    this.uri = '',
    this.duration = 0,
  }) : createdTime = createdTime ?? DateTime.now();

  /// ObjectBox internal ID.
  @internal
  @Id()
  int objectId;

  @override
  @Index(type: IndexType.value)
  @Unique(onConflict: ConflictStrategy.replace)
  final int id;

  @override
  @Property(type: PropertyType.dateNano)
  DateTime createdTime;

  @override
  String client;

  @override
  bool loading;

  @override
  bool secure;

  @override
  String method;

  @override
  String endpoint;

  @override
  String server;

  @override
  String uri;

  @override
  int duration;

  @override
  @Transient()
  NetLensHttpRequest? get request => requestRel.target;

  @override
  @Transient()
  set request(NetLensHttpRequest? value) =>
      requestRel.target = value?.toCached();

  /// [ToOne] relation of [request].
  @internal
  final ToOne<CachedNetLensHttpRequest> requestRel =
      ToOne<CachedNetLensHttpRequest>();

  @override
  @Transient()
  NetLensHttpResponse? get response => responseRel.target;

  @override
  @Transient()
  set response(NetLensHttpResponse? value) =>
      responseRel.target = value?.toCached();

  /// [ToOne] relation of [response].
  @internal
  final ToOne<CachedNetLensHttpResponse> responseRel =
      ToOne<CachedNetLensHttpResponse>();

  @override
  @Transient()
  NetLensHttpError? get error => errorRel.target;

  @override
  @Transient()
  set error(NetLensHttpError? value) => errorRel.target = value?.toCached();

  /// [ToOne] relation of [error].
  @internal
  final ToOne<CachedNetLensHttpError> errorRel =
      ToOne<CachedNetLensHttpError>();

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

  @override
  bool? get stringify => true;
}
