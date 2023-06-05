import 'package:cqrs/src/command_result.dart';
import 'package:cqrs/src/cqrs.dart';
import 'package:cqrs/src/cqrs_exception.dart';
import 'package:cqrs/src/transport_types.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements Client {}

void main() {
  group('CQRS', () {
    late MockClient client;
    late Cqrs cqrs;

    setUpAll(() {
      registerFallbackValue(Uri());
    });

    setUp(() {
      client = MockClient();
      cqrs = Cqrs(client, Uri.parse('https://example.org/api/'));
    });

    group('get', () {
      test(
          "correctly serializes query, calls client's send and"
          ' deserializes result', () async {
        mockClientPost(client, Response('true', 200));

        final result = await cqrs.get(
          ExampleQuery(),
          headers: {'X-Test': 'foobar'},
        );

        expect(result, true);

        verify(
          () => client.post(
            Uri.parse('https://example.org/api/query/ExampleQuery'),
            body: any(named: 'body'),
            headers: any(
              that: isA<Map<String, String>>()
                  .having((h) => h['X-Test'], 'X-Test', 'foobar')
                  .having(
                    (h) => h['Content-Type'],
                    'Content-Type',
                    'application/json',
                  ),
              named: 'headers',
            ),
          ),
        ).called(1);
      });

      test('correctly deserializes null query result', () async {
        mockClientPost(client, Response('null', 200));

        final result = await cqrs.get(ExampleQuery());

        expect(result, null);
      });

      test('throws CQRSException on json decoding failure', () async {
        mockClientPost(client, Response('true', 200));

        final result = cqrs.get(ExampleQueryFailingResultFactory());

        expect(
          result,
          throwsA(
            isA<CqrsException>().having(
              (e) => e.message,
              'message',
              'An error occured while decoding response body JSON:\n'
                  'Exception: This is error.',
            ),
          ),
        );
      });

      test('throws CQRSException when response code is other than 200', () {
        mockClientPost(client, Response('', 404));

        final result = cqrs.get(ExampleQuery());

        expect(
          result,
          throwsA(
            isA<CqrsException>().having(
              (e) => e.message,
              'message',
              'Invalid, non 200 status code returned by ExampleQuery query.',
            ),
          ),
        );
      });
    });

    group('run', () {
      test(
          "correctly serializes command, calls client's send and deserializes "
          'command results', () async {
        mockClientPost(
          client,
          Response('{"WasSuccessful":true,"ValidationErrors":[]}', 200),
        );

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          isA<CommandResult>().having((r) => r.success, 'success', true),
        );

        verify(
          () => client.post(
            Uri.parse('https://example.org/api/command/ExampleCommand'),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).called(1);
      });

      test('throws CQRSException on json decoding failure', () async {
        mockClientPost(client, Response('this is not a valid json', 200));

        final result = cqrs.run(ExampleCommand());

        expect(
          result,
          throwsA(
            isA<CqrsException>().having(
              (e) => e.message,
              'message',
              startsWith('An error occured while decoding response body JSON:'),
            ),
          ),
        );
      });

      test('throws CQRSException when response code is other than 200 and 422',
          () {
        mockClientPost(client, Response('', 500));

        final result = cqrs.run(ExampleCommand());

        expect(
          result,
          throwsA(
            isA<CqrsException>().having(
              (e) => e.message,
              'message',
              'Invalid, non 200 or 422 status code returned '
                  'by ExampleCommand command.',
            ),
          ),
        );
      });
    });

    group('perform', () {
      test(
          "correctly serializes operation, calls client's send and"
          ' deserializes result', () async {
        mockClientPost(client, Response('true', 200));

        final result = await cqrs.perform(
          ExampleOperation(),
          headers: {'X-Test': 'foobar'},
        );

        expect(result, true);

        verify(
          () => client.post(
            Uri.parse('https://example.org/api/operation/ExampleOperation'),
            body: any(named: 'body'),
            headers: any(
              that: isA<Map<String, String>>()
                  .having((h) => h['X-Test'], 'X-Test', 'foobar')
                  .having(
                    (h) => h['Content-Type'],
                    'Content-Type',
                    'application/json',
                  ),
              named: 'headers',
            ),
          ),
        ).called(1);
      });

      test('correctly deserializes null operation result', () async {
        mockClientPost(client, Response('null', 200));

        final result = await cqrs.perform(ExampleOperation());

        expect(result, null);
      });

      test('throws CQRSException on json decoding failure', () async {
        mockClientPost(client, Response('true', 200));

        final result = cqrs.perform(ExampleOperationFailingResultFactory());

        expect(
          result,
          throwsA(
            isA<CqrsException>().having(
              (e) => e.message,
              'message',
              'An error occured while decoding response body JSON:\n'
                  'Exception: This is error.',
            ),
          ),
        );
      });

      test('throws CQRSException when response code is other than 200', () {
        mockClientPost(client, Response('', 404));

        final result = cqrs.perform(ExampleOperation());

        expect(
          result,
          throwsA(
            isA<CqrsException>().having(
              (e) => e.message,
              'message',
              'Invalid, non 200 status code returned by ExampleOperation operation.',
            ),
          ),
        );
      });
    });
  });
}

void mockClientPost(MockClient client, Response response) {
  when(
    () => client.post(
      any(),
      body: any(named: 'body'),
      headers: any(named: 'headers'),
    ),
  ).thenAnswer((_) async => response);
}

class ExampleQuery implements Query<bool?> {
  @override
  String getFullName() => 'ExampleQuery';

  @override
  bool? resultFactory(dynamic json) => json as bool?;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class ExampleQueryFailingResultFactory implements Query<bool> {
  @override
  String getFullName() => 'ExampleQuery';

  @override
  bool resultFactory(dynamic json) => throw Exception('This is error.');

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class ExampleOperation implements Operation<bool?> {
  @override
  String getFullName() => 'ExampleOperation';

  @override
  bool? resultFactory(dynamic json) => json as bool?;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class ExampleOperationFailingResultFactory implements Operation<bool> {
  @override
  String getFullName() => 'ExampleOperation';

  @override
  bool resultFactory(dynamic json) => throw Exception('This is error.');

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class ExampleCommand implements Command {
  @override
  String getFullName() => 'ExampleCommand';

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{};
}
