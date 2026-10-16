import 'package:alice/helper/alice_graphql.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:test/test.dart';

AliceHttpCall _call({
  String method = 'POST',
  dynamic body,
  Map<String, dynamic> query = const {},
  dynamic responseBody,
}) =>
    AliceHttpCall(1)
      ..method = method
      ..endpoint = '/graphql'
      ..request =
          (AliceHttpRequest()
            ..body = body
            ..queryParameters = query)
      ..response = (AliceHttpResponse()..body = responseBody);

void main() {
  group('AliceGraphQL', () {
    test('reads operation type and name from the document', () {
      final AliceGraphQLOperation? operation = AliceGraphQL.detect(
        _call(
          body:
              '{"query": "# comment\\nmutation Login(\$e: String) { login }"}',
        ),
      );
      expect(operation?.type, AliceGraphQLOperationType.mutation);
      expect(operation?.name, 'Login');
      expect(operation?.title, 'mutation Login');
    });

    test('prefers operationName and treats shorthand as query', () {
      final AliceGraphQLOperation? operation = AliceGraphQL.detect(
        _call(body: {'query': '{ me { id } }', 'operationName': 'Me'}),
      );
      expect(operation?.type, AliceGraphQLOperationType.query);
      expect(operation?.title, 'query Me');
    });

    test('detects batches, GET requests and errors', () {
      expect(
        AliceGraphQL.detect(
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
        AliceGraphQL.detect(
          _call(method: 'GET', query: {'query': 'query Feed { feed }'}),
        )?.name,
        'Feed',
      );
      expect(
        AliceGraphQL.detect(
          _call(
            body: {'query': 'query A { a }'},
            responseBody: '{"data": null, "errors": [{"message": "x"}]}',
          ),
        )?.hasErrors,
        true,
      );
    });

    test('ignores bodies which are not GraphQL', () {
      expect(AliceGraphQL.detect(_call(body: {'query': 'search text'})), null);
      expect(AliceGraphQL.detect(_call(body: '{"name": "a"}')), null);
      expect(AliceGraphQL.detect(_call(body: 'query A { a }')), null);
    });
  });
}
