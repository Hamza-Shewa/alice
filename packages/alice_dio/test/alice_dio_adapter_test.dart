import 'dart:io';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/model/alice_log.dart';
import 'package:alice/model/alice_replay_request.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:alice_test/alice_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart' as http_mock_adapter;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  late AliceCore aliceCore;
  late AliceDioAdapter aliceDioAdapter;
  late Dio dio;
  late http_mock_adapter.DioAdapter dioAdapter;
  setUp(() {
    registerFallbackValue(AliceHttpCall(0));
    registerFallbackValue(AliceHttpResponse());
    registerFallbackValue(AliceHttpError());
    registerFallbackValue(AliceLog(message: ''));

    aliceCore = AliceCoreMock();
    when(() => aliceCore.addCall(any())).thenAnswer((_) => {});
    when(() => aliceCore.addResponse(any(), any())).thenAnswer((_) => {});
    when(() => aliceCore.addError(any(), any())).thenAnswer((_) => {});
    when(() => aliceCore.addLog(any())).thenAnswer((_) => {});

    aliceDioAdapter = AliceDioAdapter();
    aliceDioAdapter.injectCore(aliceCore);

    dio = Dio(BaseOptions(followRedirects: false))
      ..interceptors.add(aliceDioAdapter);
    dioAdapter = http_mock_adapter.DioAdapter(dio: dio);
  });

  group("AliceDioAdapter", () {
    test("should record call when URL can't be parsed", () async {
      dio.options.baseUrl = 'http://192.168.1.1:505';

      await expectLater(dio.get<void>('api/login'), throwsA(anything));

      final call =
          verify(() => aliceCore.addCall(captureAny())).captured.single
              as AliceHttpCall;
      expect(call.uri, 'http://192.168.1.1:505api/login');
      expect(call.server, '192.168.1.1:505api');
      expect(call.endpoint, '/login');
      expect(call.method, 'GET');
      expect(call.secure, false);
    });

    test("should handle GET call with json response", () async {
      dioAdapter.onGet(
        'https://test.com/json',
        (server) => server.reply(
          200,
          '{"result": "ok"}',
          headers: {
            "content-type": ["application/json"],
          },
        ),
        headers: {"content-type": "application/json"},
      );

      await dio.get<void>(
        'https://test.com/json',
        options: Options(headers: {"content-type": "application/json"}),
      );

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        headers: {"content-type": "application/json"},
        contentType: "application/json",
        queryParameters: {},
      );

      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
        checkId: true,
        checkTime: true,
        secured: true,
        loading: true,
        client: 'Dio',
        method: 'GET',
        endpoint: '/json',
        server: 'test.com',
        uri: 'https://test.com/json',
        duration: 0,
        request: requestMatcher,
        response: responseMatcher,
      );

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 200,
        size: 16,
        checkTime: true,
        body: '{"result": "ok"}',
        headers: {'content-type': '[application/json]'},
      );

      verify(
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );
    });

    test("should handle POST call with json response", () async {
      dioAdapter.onPost(
        'https://test.com/json',
        (server) => server.reply(
          200,
          '{"result": "ok"}',
          headers: {
            "content-type": ["application/json"],
          },
        ),
        data: '{"data":"test"}',
        headers: {"content-type": "application/json"},
        queryParameters: {"sort": "asc"},
      );

      await dio.post<void>(
        'https://test.com/json',
        data: '{"data":"test"}',
        queryParameters: {"sort": "asc"},
        options: Options(headers: {"content-type": "application/json"}),
      );

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        headers: {"content-type": "application/json"},
        contentType: "application/json",
        body: '{"data":"test"}',
        queryParameters: {"sort": "asc"},
      );

      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
        checkId: true,
        checkTime: true,
        secured: true,
        loading: true,
        client: 'Dio',
        method: 'POST',
        endpoint: '/json',
        server: 'test.com',
        uri: 'https://test.com/json?sort=asc',
        duration: 0,
        request: requestMatcher,
        response: responseMatcher,
      );

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 200,
        size: 16,
        checkTime: true,
        body: '{"result": "ok"}',
        headers: {'content-type': '[application/json]'},
      );

      verify(
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );
    });

    test("should handle form data", () async {
      final name = '${DateTime.now().microsecondsSinceEpoch}.png';
      // Create the file in a temporary folder, so the test leaves no files
      // behind.
      final directory = Directory.systemTemp.createTempSync('alice_dio_test');
      addTearDown(() => directory.deleteSync(recursive: true));
      final file = File('${directory.path}/$name');
      file.createSync();

      var formData = FormData.fromMap({
        'name': 'Alice',
        'surname': 'test',
        // Dio infers the content type from the file name in newer versions,
        // so set it explicitly.
        'image': MultipartFile.fromFileSync(
          file.path,
          contentType: DioMediaType('application', 'octet-stream'),
        ),
      });

      dioAdapter.onPost(
        'https://test.com/form',
        (server) => server.reply(200, '{"result": "ok"}'),
        data: formData,
      );

      await dio.post<void>('https://test.com/form', data: formData);

      final requestMatcher = buildRequestMatcher(
        checkTime: true,
        formDataFields: [
          const AliceFormDataField('name', 'Alice'),
          const AliceFormDataField('surname', 'test'),
        ],
        formDataFiles: [AliceFormDataFile(name, "application/octet-stream", 0)],
        body: 'Form data',
        headers: {'content-type': 'multipart/form-data'},
      );
      final responseMatcher = buildResponseMatcher(checkTime: true);

      final callMatcher = buildCallMatcher(
        checkId: true,
        checkTime: true,
        secured: true,
        loading: true,
        client: 'Dio',
        method: 'POST',
        endpoint: '/form',
        server: 'test.com',
        uri: 'https://test.com/form',
        duration: 0,
        request: requestMatcher,
        response: responseMatcher,
      );

      verify(() => aliceCore.addCall(any(that: callMatcher)));

      final nextResponseMatcher = buildResponseMatcher(
        status: 200,
        size: 16,
        checkTime: true,
        body: '{"result": "ok"}',
        headers: {'content-type': '[application/json]'},
      );

      verify(
        () => aliceCore.addResponse(any(that: nextResponseMatcher), any()),
      );
      file.deleteSync();
    });
  });

  test("should handle call with empty response", () async {
    dioAdapter.onGet(
      'https://test.com/json',
      (server) => server.reply(200, null),
      headers: {"content-type": "application/json"},
    );

    await dio.get<void>(
      'https://test.com/json',
      options: Options(headers: {"content-type": "application/json"}),
    );

    final requestMatcher = buildRequestMatcher(
      checkTime: true,
      headers: {"content-type": "application/json"},
      contentType: "application/json",
      queryParameters: {},
    );

    final responseMatcher = buildResponseMatcher(checkTime: true);

    final callMatcher = buildCallMatcher(
      checkId: true,
      checkTime: true,
      secured: true,
      loading: true,
      client: 'Dio',
      method: 'GET',
      endpoint: '/json',
      server: 'test.com',
      uri: 'https://test.com/json',
      duration: 0,
      request: requestMatcher,
      response: responseMatcher,
    );

    verify(() => aliceCore.addCall(any(that: callMatcher)));

    final nextResponseMatcher = buildResponseMatcher(
      status: 200,
      size: 0,
      checkTime: true,
      body: '',
    );

    verify(() => aliceCore.addResponse(any(that: nextResponseMatcher), any()));
  });

  test("should handle call with error", () async {
    dioAdapter.onGet(
      'https://test.com/json',
      (server) => server.reply(500, ''),
      headers: {"content-type": "application/json"},
    );

    try {
      await dio.get<void>(
        'https://test.com/json',
        options: Options(headers: {"content-type": "application/json"}),
      );
    } catch (_) {}

    final requestMatcher = buildRequestMatcher(
      checkTime: true,
      headers: {"content-type": "application/json"},
      contentType: "application/json",
      queryParameters: {},
    );

    final responseMatcher = buildResponseMatcher(checkTime: true);

    final callMatcher = buildCallMatcher(
      checkId: true,
      checkTime: true,
      secured: true,
      loading: true,
      client: 'Dio',
      method: 'GET',
      endpoint: '/json',
      server: 'test.com',
      uri: 'https://test.com/json',
      duration: 0,
      request: requestMatcher,
      response: responseMatcher,
    );

    verify(() => aliceCore.addCall(any(that: callMatcher)));

    final nextResponseMatcher = buildResponseMatcher(
      status: 500,
      size: 0,
      checkTime: true,
      headers: {'content-type': '[application/json]'},
    );

    verify(() => aliceCore.addResponse(any(that: nextResponseMatcher), any()));

    final errorMatcher = buildErrorMatcher(
      checkError: true,
      checkStacktrace: true,
    );

    verify(() => aliceCore.addError(any(that: errorMatcher), any()));

    final logMatcher = buildLogMatcher(
      checkMessage: true,
      checkError: true,
      checkStacktrace: true,
      checkTime: true,
    );
    verify(() => aliceCore.addLog(any(that: logMatcher)));
  });

  test("should handle call with error where response is null", () async {
    dioAdapter.onGet(
      'https://test.com/json',
      (server) =>
          server.throws(0, DioException(requestOptions: RequestOptions())),
      headers: {"content-type": "application/json"},
    );

    try {
      await dio.get<void>(
        'https://test.com/json',
        options: Options(headers: {"content-type": "application/json"}),
      );
    } catch (_) {}

    final nextResponseMatcher = buildResponseMatcher(
      status: -1,
      size: 0,
      checkTime: true,
    );

    verify(() => aliceCore.addResponse(any(that: nextResponseMatcher), any()));
  });

  test("should handle call with error where response is not null", () async {
    dioAdapter.onGet(
      'https://test.com/json',
      (server) => server.throws(
        0,
        DioException(
          requestOptions: RequestOptions(),
          response: Response(requestOptions: RequestOptions(), data: "{}"),
        ),
      ),
      headers: {"content-type": "application/json"},
    );

    try {
      await dio.get<void>(
        'https://test.com/json',
        options: Options(headers: {"content-type": "application/json"}),
      );
    } catch (_) {}

    final nextResponseMatcher = buildResponseMatcher(
      size: 2,
      body: '{}',
      checkTime: true,
    );

    verify(() => aliceCore.addResponse(any(that: nextResponseMatcher), any()));
  });

  group("replay", () {
    test("should replay only calls made by Dio", () {
      expect(aliceDioAdapter.canReplay(AliceHttpCall(1)..client = 'Dio'), true);
      expect(
        aliceDioAdapter.canReplay(AliceHttpCall(1)..client = 'Chopper'),
        false,
      );
    });

    test("should send request again through the replay client", () async {
      aliceDioAdapter.replayClient = dio;
      dioAdapter.onPost(
        'https://test.com/items',
        (server) => server.reply(201, '{"id": 2}'),
        data: '{"name":"a"}',
        headers: {'x-token': 'abc'},
      );

      await aliceDioAdapter.replay(
        const AliceReplayRequest(
          method: 'POST',
          url: 'https://test.com/items',
          headers: {'x-token': 'abc'},
          body: '{"name":"a"}',
        ),
      );

      final call =
          verify(() => aliceCore.addCall(captureAny())).captured.single
              as AliceHttpCall;
      expect(call.method, 'POST');
      expect(call.uri, 'https://test.com/items');
      expect(call.request?.headers['x-token'], 'abc');
      verify(
        () => aliceCore.addResponse(
          any(that: buildResponseMatcher(status: 201)),
          any(),
        ),
      );
    });

    test("should record error responses without throwing", () async {
      aliceDioAdapter.replayClient = dio;
      dioAdapter.onGet(
        'https://test.com/missing',
        (server) => server.reply(404, '{"error": "not found"}'),
      );

      await aliceDioAdapter.replay(
        const AliceReplayRequest(
          method: 'GET',
          url: 'https://test.com/missing',
        ),
      );

      verify(
        () => aliceCore.addResponse(
          any(that: buildResponseMatcher(status: 404)),
          any(),
        ),
      );
    });
  });
}
