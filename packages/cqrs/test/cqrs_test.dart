import 'dart:convert';
import 'dart:io';

import 'package:cqrs/cqrs.dart';
import 'package:cqrs/src/cqrs_middleware.dart';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements Client {}

class MockLogger extends Mock implements Logger {}

class MockCqrsMiddleware extends Mock implements CqrsMiddleware {}

void main() {
  group('CQRS', () {
    late MockClient client;
    late MockLogger logger;
    late MockCqrsMiddleware middleware;
    late Cqrs cqrs;

    setUpAll(() {
      registerFallbackValue(Uri());
      registerFallbackValue(const QSuccess<bool?>(true));
      registerFallbackValue(
        Future.value(const QSuccess<bool?>(true)),
      );
      registerFallbackValue(const CqrsCommandSuccess());
      registerFallbackValue(
        Future.value(const CqrsCommandSuccess()),
      );
      registerFallbackValue(const CqrsOperationSuccess<bool?>(true));
      registerFallbackValue(
        Future.value(const CqrsOperationSuccess<bool?>(true)),
      );
    });

    setUp(() {
      client = MockClient();
      logger = MockLogger();
      middleware = MockCqrsMiddleware();
      cqrs = Cqrs(
        client,
        Uri.parse('https://example.org/api/'),
        logger: logger,
      );
    });

    group('addMiddleware', () {
      test('adds new middleware to the list', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareQueryResult(middleware, result);
        verifyNever(() => middleware.handleQueryResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareQueryResult(middleware, result);
        verify(() => middleware.handleQueryResult(result)).called(1);

        cqrs.removeMiddleware(middleware);
      });
    });

    group('removeMiddleware', () {
      test('removes given middleware from the list', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareQueryResult(middleware, result);

        verifyNever(() => middleware.handleQueryResult(result));

        cqrs.addMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareQueryResult(middleware, result);

        verify(() => middleware.handleQueryResult(result)).called(1);

        cqrs.removeMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareQueryResult(middleware, result);

        verifyNever(
          () => middleware.handleQueryResult(any()),
        );
      });
    });

    group('get', () {
      test(
          "correctly serializes query, calls client's send,"
          ' deserializes result and logs result', () async {
        mockClientPost(client, Response('true', 200));

        final result = await cqrs.get(
          ExampleQuery(),
          headers: {'X-Test': 'foobar'},
        );

        expect(result, const QSuccess<bool?>(true));

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

        verify(
          () => logger.info('Query ExampleQuery executed successfully.'),
        ).called(1);
      });

      test('correctly deserializes null query result', () async {
        mockClientPost(client, Response('null', 200));

        final result = await cqrs.get(ExampleQuery());

        expect(result, const QSuccess<bool?>(null));
      });

      test(
          'returns QFailure(CqrsError.unknown) on json decoding'
          ' failure and logs result', () async {
        mockClientPost(client, Response('true', 200));

        final result = await cqrs.get(ExampleQueryFailingResultFactory());

        expect(
          result,
          const QFailure<bool>(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Query ExampleQueryFailingResultFactory failed while decoding'
            ' response body JSON.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns QFailure(CqrsError.network) on socket exception'
          ' and logs result', () async {
        mockClientException(
          client,
          const SocketException('This might be socket exception'),
        );

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QFailure<bool?>(CqrsError.network),
        );

        verify(
          () => logger.severe(
            'Query ExampleQuery failed with network error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns QFailure(CqrsError.unknown) on client exception'
          ' and logs result', () async {
        final exception = Exception('This is not a socket exception');
        mockClientException(client, exception);

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QFailure<bool?>(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Query ExampleQuery failed unexpectedly.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns QFailure(CqrsError.authentication) when response'
          ' code is 401 and logs result', () async {
        mockClientPost(client, Response('', 401));

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QFailure<bool?>(CqrsError.authentication),
        );

        verify(
          () => logger.severe(
            'Query ExampleQuery failed with authentication error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns QFailure(CqrsError.forbiddenAccess) when response'
          ' code is 403 and logs result', () async {
        mockClientPost(client, Response('', 403));

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QFailure<bool?>(CqrsError.forbiddenAccess),
        );

        verify(
          () => logger.severe(
            'Query ExampleQuery failed with forbidden access error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns QFailure(CqrsError.unknown) for other response'
          ' codes and logs result', () async {
        mockClientPost(client, Response('', 404));

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QFailure<bool?>(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Query ExampleQuery failed unexpectedly.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'calls CqrsMiddleware.handleQueryResult for each'
          ' middleware present', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareQueryResult(middleware, result);
        verifyNever(() => middleware.handleQueryResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareQueryResult(middleware, result);
        verify(() => middleware.handleQueryResult(result)).called(1);
      });
    });

    group('run', () {
      test(
          "correctly serializes command, calls client's send, deserializes "
          'command results and logs result', () async {
        mockClientPost(
          client,
          Response('{"WasSuccessful":true,"ValidationErrors":[]}', 200),
        );

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandSuccess(),
        );

        verify(
          () => client.post(
            Uri.parse('https://example.org/api/command/ExampleCommand'),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).called(1);

        verify(
          () => logger.info(
            'Command ExampleCommand executed successfully.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsCommandFailure(CqrsError.validation) if any validation '
          'error occured and logs result', () async {
        const validationError = ValidationError(
          400,
          'Error message',
          'invalidProperty',
        );

        mockClientPost(
          client,
          Response(
            '{"WasSuccessful":false,"ValidationErrors":[${jsonEncode(validationError)}]}',
            422,
          ),
        );

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandFailure(
            CqrsError.validation,
            validationErrors: [validationError],
          ),
        );

        verify(
          () => client.post(
            Uri.parse('https://example.org/api/command/ExampleCommand'),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).called(1);

        verify(
          () => logger.warning(
            'Command ExampleCommand failed with validation errors:\n'
            'Error message (400), ',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsCommandFailure(CqrsError.unknown) on json decoding'
          ' failure and logs result', () async {
        mockClientPost(client, Response('this is not a valid json', 200));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandFailure(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Command ExampleCommand failed while decoding response body JSON.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsCommandFailure(CqrsError.network) on socket exception'
          ' and logs result', () async {
        mockClientException(
          client,
          const SocketException('This might be socket exception'),
        );

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandFailure(CqrsError.network),
        );

        verify(
          () => logger.severe(
            'Command ExampleCommand failed with network error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsCommandFailure(CqrsError.unknown) on other'
          ' client exceptions and logs result', () async {
        mockClientException(
          client,
          Exception('This is not a socket exception'),
        );

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandFailure(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Command ExampleCommand failed unexpectedly.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsCommandFailure(CqrsError.authentication) when'
          ' response code is 401 and logs result', () async {
        mockClientPost(client, Response('', 401));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandFailure(CqrsError.authentication),
        );

        verify(
          () => logger.severe(
            'Command ExampleCommand failed with authentication error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsCommandFailure(CqrsError.forbiddenAccess) when'
          ' response code is 403 and logs result', () async {
        mockClientPost(client, Response('', 403));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandFailure(CqrsError.forbiddenAccess),
        );

        verify(
          () => logger.severe(
            'Command ExampleCommand failed with forbidden access error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsCommandFailure(CqrsError.unknown) for other'
          ' response codes and logs result', () async {
        mockClientPost(client, Response('', 404));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CqrsCommandFailure(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Command ExampleCommand failed unexpectedly.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'calls CqrsMiddleware.handleCommandResult for each'
          ' middleware present', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.run(ExampleCommand());
        mockCqrsMiddlewareCommandResult(middleware, result);
        verifyNever(() => middleware.handleCommandResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.run(ExampleCommand());
        mockCqrsMiddlewareCommandResult(middleware, result);
        verify(() => middleware.handleCommandResult(result)).called(1);
      });
    });

    group('perform', () {
      test(
          "correctly serializes operation, calls client's send,"
          ' deserializes result and logs result', () async {
        mockClientPost(client, Response('true', 200));

        final result = await cqrs.perform(
          ExampleOperation(),
          headers: {'X-Test': 'foobar'},
        );

        expect(result, const CqrsOperationSuccess<bool?>(true));

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

        verify(
          () =>
              logger.info('Operation ExampleOperation executed successfully.'),
        ).called(1);
      });

      test('correctly deserializes null operation result', () async {
        mockClientPost(client, Response('null', 200));

        final result = await cqrs.perform(ExampleOperation());

        expect(result, const CqrsOperationSuccess<bool?>(null));
      });

      test(
          'returns CqrsOperationFailure(CqrsError.unknown) on json decoding'
          ' failure and logs result', () async {
        mockClientPost(client, Response('true', 200));

        final result =
            await cqrs.perform(ExampleOperationFailingResultFactory());

        expect(
          result,
          const CqrsOperationFailure<bool>(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Operation ExampleOperationFailingResultFactory failed while decoding'
            ' response body JSON.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsOperationFailure(CqrsError.network) on socket exception'
          ' and logs result', () async {
        mockClientException(
          client,
          const SocketException('This might be socket exception'),
        );

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const CqrsOperationFailure<bool?>(CqrsError.network),
        );

        verify(
          () => logger.severe(
            'Operation ExampleOperation failed with network error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsOperationFailure(CqrsError.unknown) on client exception'
          ' and logs result', () async {
        final exception = Exception('This is not a socket exception');
        mockClientException(client, exception);

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const CqrsOperationFailure<bool?>(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Operation ExampleOperation failed unexpectedly.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsOperationFailure(CqrsError.authentication) when response'
          ' code is 401 and logs result', () async {
        mockClientPost(client, Response('', 401));

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const CqrsOperationFailure<bool?>(
            CqrsError.authentication,
          ),
        );

        verify(
          () => logger.severe(
            'Operation ExampleOperation failed with authentication error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsOperationFailure(CqrsError.forbiddenAccess) when response'
          ' code is 403 and logs result', () async {
        mockClientPost(client, Response('', 403));

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const CqrsOperationFailure<bool?>(
            CqrsError.forbiddenAccess,
          ),
        );

        verify(
          () => logger.severe(
            'Operation ExampleOperation failed with forbidden access error.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'returns CqrsOperationFailure(CqrsError.unknown) for other response'
          ' codes and logs result', () async {
        mockClientPost(client, Response('', 404));

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const CqrsOperationFailure<bool?>(CqrsError.unknown),
        );

        verify(
          () => logger.severe(
            'Operation ExampleOperation failed unexpectedly.',
            any(),
            any(),
          ),
        ).called(1);
      });

      test(
          'calls CqrsMiddleware.handleOperationResult for each'
          ' middleware present', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.perform(ExampleOperation());
        mockCqrsMiddlewareOperationResult(middleware, result);
        verifyNever(() => middleware.handleOperationResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.perform(ExampleOperation());
        mockCqrsMiddlewareOperationResult(middleware, result);
        verify(() => middleware.handleOperationResult(result)).called(1);
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

void mockClientException(MockClient client, Exception exception) {
  when(
    () => client.post(
      any(),
      body: any(named: 'body'),
      headers: any(named: 'headers'),
    ),
  ).thenAnswer((_) async => throw exception);
}

void mockCqrsMiddlewareQueryResult(
  MockCqrsMiddleware middleware,
  QResult<bool?> result,
) {
  when(
    () => middleware.handleQueryResult(result),
  ).thenAnswer(
    (_) async => Future.value(result),
  );
}

void mockCqrsMiddlewareCommandResult(
  MockCqrsMiddleware middleware,
  CqrsCommandResult result,
) {
  when(
    () => middleware.handleCommandResult(result),
  ).thenAnswer(
    (_) async => Future.value(result),
  );
}

void mockCqrsMiddlewareOperationResult(
  MockCqrsMiddleware middleware,
  CqrsOperationResult<bool?> result,
) {
  when(
    () => middleware.handleOperationResult(result),
  ).thenAnswer(
    (_) async => Future.value(result),
  );
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
