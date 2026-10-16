import 'package:netlens/helper/netlens_graphql.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_http_request.dart';
import 'package:netlens/model/netlens_http_response.dart';
import 'package:test/test.dart';

NetLensHttpCall _call({
  String method = 'POST',
  dynamic body,
  Map<String, dynamic> query = const {},
  dynamic responseBody,
}) =>
    NetLensHttpCall(1)
      ..method = method
      ..endpoint = '/graphql'
      ..request =
          (NetLensHttpRequest()
            ..body = body
            ..queryParameters = query)
      ..response = (NetLensHttpResponse()..body = responseBody);

void main() {
  group('NetLensGraphQL', () {
    test('reads operation type and name from the document', () {
      final NetLensGraphQLOperation? operation = NetLensGraphQL.detect(
        _call(
          body:
              '{"query": "# comment\\nmutation Login(\$e: String) { login }"}',
        ),
      );
      expect(operation?.type, NetLensGraphQLOperationType.mutation);
      expect(operation?.name, 'Login');
      expect(operation?.title, 'mutation Login');
    });

    test('prefers operationName and treats shorthand as query', () {
      final NetLensGraphQLOperation? operation = NetLensGraphQL.detect(
        _call(body: {'query': '{ me { id } }', 'operationName': 'Me'}),
      );
      expect(operation?.type, NetLensGraphQLOperationType.query);
      expect(operation?.title, 'query Me');
    });

    test('detects batches, GET requests and errors', () {
      expect(
        NetLensGraphQL.detect(
          _call(
            body: [
              {'query': 'query A { a }'},
              {'query': 'query B { b }'},
            ],
          ),
        )?.title,
        'query A +1',
      );
      expect(
        NetLensGraphQL.detect(
          _call(method: 'GET', query: {'query': 'query Feed { feed }'}),
        )?.name,
        'Feed',
      );
      expect(
        NetLensGraphQL.detect(
          _call(
            body: {'query': 'query A { a }'},
            responseBody: '{"data": null, "errors": [{"message": "x"}]}',
          ),
        )?.hasErrors,
        true,
      );
    });

    test('ignores bodies which are not GraphQL', () {
      expect(
        NetLensGraphQL.detect(_call(body: {'query': 'search text'})),
        null,
      );
      expect(NetLensGraphQL.detect(_call(body: '{"name": "a"}')), null);
      expect(NetLensGraphQL.detect(_call(body: 'query A { a }')), null);
    });
  });
}
