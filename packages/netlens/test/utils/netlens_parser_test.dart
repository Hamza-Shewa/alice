import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/utils/netlens_parser.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mock/build_context_mock.dart';

void main() {
  late BuildContext context;
  setUp(() {
    registerFallbackValue(NetLensTranslationKey.accept);
    context = BuildContextMock();
  });

  group("NetLensBodyParser", () {
    test("should parse json body and pretty print it", () {
      expect(
        NetLensParser.formatBody(
          context: context,
          body: '{"id": 1, "name": "test}',
          contentType: "application/json",
        ),
        '"{\\"id\\": 1, \\"name\\": \\"test}"',
      );
    });

    test("should parse unknown body", () {
      expect(NetLensParser.formatBody(context: context, body: 'test'), 'test');
    });

    test("should parse empty body", () {
      expect(
        NetLensParser.formatBody(context: context, body: ''),
        "Body is empty",
      );
    });

    test("should parse application/json content type", () {
      expect(
        NetLensParser.getContentType(
          context: context,
          headers: {'Content-Type': "application/json"},
        ),
        "application/json",
      );

      expect(
        NetLensParser.getContentType(
          context: context,
          headers: {'content-type': "application/json"},
        ),
        "application/json",
      );
    });

    test("should parse unknown content type", () {
      expect(
        NetLensParser.getContentType(context: context, headers: {}),
        "Unknown",
      );
    });

    test("should parse headers", () {
      expect(NetLensParser.parseHeaders(headers: {"id": 0}), {"id": "0"});
      expect(NetLensParser.parseHeaders(headers: {"id": "0"}), {"id": "0"});
    });

    test("should not parse headers", () {
      expect(
        () => NetLensParser.parseHeaders(headers: "test"),
        throwsArgumentError,
      );
    });
  });
}
