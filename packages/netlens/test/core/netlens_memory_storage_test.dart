// ignore_for_file: require_trailing_commas

import 'package:netlens/core/netlens_memory_storage.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_error.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mock/mocked_data.dart';

void main() {
  late NetLensMemoryStorage storage;
  setUp(() {
    storage = NetLensMemoryStorage(maxCallsCount: 1000);
  });

  group("NetLensMemoryStorage", () {
    test("should return HTTP call stats", () {
      expect(storage.getStats(), (
        total: 0,
        successes: 0,
        redirects: 0,
        errors: 0,
        loading: 0,
      ));

      storage.addCall(
        MockedData.getHttpCallWithResponseStatus(statusCode: 200),
      );
      storage.addCall(
        MockedData.getHttpCallWithResponseStatus(statusCode: 201),
      );
      storage.addCall(
        MockedData.getHttpCallWithResponseStatus(statusCode: 300),
      );
      storage.addCall(
        MockedData.getHttpCallWithResponseStatus(statusCode: 301),
      );
      storage.addCall(
        MockedData.getHttpCallWithResponseStatus(statusCode: 400),
      );
      storage.addCall(
        MockedData.getHttpCallWithResponseStatus(statusCode: 404),
      );
      storage.addCall(
        MockedData.getHttpCallWithResponseStatus(statusCode: 500),
      );
      storage.addCall(MockedData.getLoadingHttpCall());
      storage.addCall(MockedData.getHttpCallWithResponseStatus(statusCode: -1));
      storage.addCall(MockedData.getHttpCallWithResponseStatus(statusCode: 0));

      expect(storage.getStats(), (
        total: 10,
        successes: 2,
        redirects: 2,
        errors: 5,
        loading: 1,
      ));
    });

    test("should save HTTP calls", () {
      final httpCall = NetLensHttpCall(1);
      httpCall.request = NetLensHttpRequest();
      httpCall.response = NetLensHttpResponse();

      storage.addCall(httpCall);
      expect(storage.getCalls(), [httpCall]);

      final anotherHttpCall = NetLensHttpCall(1);
      anotherHttpCall.request = NetLensHttpRequest();
      anotherHttpCall.response = NetLensHttpResponse();

      storage.addCall(anotherHttpCall);
      expect(storage.getCalls(), [httpCall, anotherHttpCall]);
    });

    test("should replace HTTP call if over limit", () {
      storage = NetLensMemoryStorage(maxCallsCount: 2);
      final firstCall = MockedData.getLoadingHttpCall();
      final secondCall = MockedData.getLoadingHttpCall();
      final thirdCall = MockedData.getLoadingHttpCall();

      storage.addCall(firstCall);
      storage.addCall(secondCall);
      storage.addCall(thirdCall);

      expect(storage.getCalls(), [secondCall, thirdCall]);
    });

    test("should add error to HTTP call", () {
      final call = MockedData.getLoadingHttpCall();
      final error = NetLensHttpError()..error = "Some error";

      storage.addCall(call);
      storage.addError(error, call.id);

      expect(storage.getCalls().first.error != null, true);
    });

    test("should not add error to HTTP call if HTTP has been not found", () {
      final call = MockedData.getLoadingHttpCall();
      final error = NetLensHttpError()..error = "Some error";

      storage.addCall(call);
      storage.addError(error, 100);

      expect(storage.getCalls().first.error != null, false);
    });

    test("should add response to HTTP call", () {
      final call = MockedData.getLoadingHttpCall();
      final response = NetLensHttpResponse();

      storage.addCall(call);
      storage.addResponse(response, call.id);

      final savedCall = storage.getCalls().first;
      expect(savedCall.response != null, true);
      expect(savedCall.loading, false);
      expect(savedCall.duration > 0, true);
    });

    test("should not add response to HTTP call if HTTP has been not found", () {
      final call = MockedData.getLoadingHttpCall();
      final response = NetLensHttpResponse();

      storage.addCall(call);
      storage.addResponse(response, 100);

      expect(storage.getCalls().first.response != null, false);
    });

    test("should remove all calls", () {
      storage.addCall(MockedData.getLoadingHttpCall());
      storage.addCall(MockedData.getLoadingHttpCall());
      storage.addCall(MockedData.getLoadingHttpCall());

      expect(storage.getCalls().length, 3);

      storage.removeCalls();

      expect(storage.getCalls().length, 0);
    });

    test("should return call if call exists", () {
      final call = MockedData.getHttpCall(id: 0);
      storage.addCall(call);

      expect(call, storage.selectCall(0));
    });

    test("should return null if call doesn't exist", () {
      expect(null, storage.selectCall(1));
    });
  });
}
