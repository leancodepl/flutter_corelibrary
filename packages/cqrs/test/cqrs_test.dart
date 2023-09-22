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
      registerFallbackValue(const QuerySuccess<bool?>(true));
      registerFallbackValue(
        Future.value(const QuerySuccess<bool?>(true)),
      );
      registerFallbackValue(const CommandSuccess(null));
      registerFallbackValue(
        Future.value(const CommandSuccess(null)),
      );
      registerFallbackValue(const OperationSuccess<bool?>(true));
      registerFallbackValue(
        Future.value(const OperationSuccess<bool?>(true)),
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
        mockCqrsMiddlewareHandleResult(middleware, result);
        verifyNever(() => middleware.handleResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareHandleResult(middleware, result);
        verify(() => middleware.handleResult(result)).called(1);

        cqrs.removeMiddleware(middleware);
      });
    });

    group('removeMiddleware', () {
      test('removes given middleware from the list', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareHandleResult(middleware, result);

        verifyNever(() => middleware.handleResult(result));

        cqrs.addMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareHandleResult(middleware, result);

        verify(() => middleware.handleResult(result)).called(1);

        cqrs.removeMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareHandleResult(middleware, result);

        verifyNever(
          () => middleware.handleResult(any()),
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

        expect(result, const QuerySuccess<bool?>(true));

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

        expect(result, const QuerySuccess<bool?>(null));
      });

      test(
          'returns QueryFailure(CqrsError.unknown) on json decoding'
          ' failure and logs result', () async {
        mockClientPost(client, Response('true', 200));

        final result = await cqrs.get(ExampleQueryFailingResultFactory());

        expect(
          result,
          const QueryFailure<bool>(QueryErrorType.unknown),
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
          'returns QueryFailure(CqrsError.network) on socket exception'
          ' and logs result', () async {
        mockClientException(
          client,
          const SocketException('This might be socket exception'),
        );

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QueryFailure<bool?>(QueryErrorType.network),
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
          'returns QueryFailure(CqrsError.unknown) on client exception'
          ' and logs result', () async {
        final exception = Exception('This is not a socket exception');
        mockClientException(client, exception);

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QueryFailure<bool?>(QueryErrorType.unknown),
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
          'returns QueryFailure(CqrsError.authentication) when response'
          ' code is 401 and logs result', () async {
        mockClientPost(client, Response('', 401));

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QueryFailure<bool?>(QueryErrorType.authentication),
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
          'returns QueryFailure(CqrsError.forbiddenAccess) when response'
          ' code is 403 and logs result', () async {
        mockClientPost(client, Response('', 403));

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QueryFailure<bool?>(QueryErrorType.forbiddenAccess),
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
          'returns QueryFailure(CqrsError.unknown) for other response'
          ' codes and logs result', () async {
        mockClientPost(client, Response('', 404));

        final result = await cqrs.get(ExampleQuery());

        expect(
          result,
          const QueryFailure<bool?>(QueryErrorType.unknown),
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
          'calls CqrsMiddleware.handleResult for each'
          ' middleware present', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareHandleResult(middleware, result);
        verifyNever(() => middleware.handleResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.get(ExampleQuery());
        mockCqrsMiddlewareHandleResult(middleware, result);
        verify(() => middleware.handleResult(result)).called(1);
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
          const CommandSuccess(null),
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
          'returns CommandFailure(CommandErrorType.validation) if any validation '
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
          const CommandFailure(
            CommandErrorType.validation,
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
          'returns CommandFailure(CommandErrorType.unknown) on json decoding'
          ' failure and logs result', () async {
        mockClientPost(client, Response('this is not a valid json', 200));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CommandFailure(CommandErrorType.unknown),
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
          'returns CommandFailure(CommandErrorType.network) on socket exception'
          ' and logs result', () async {
        mockClientException(
          client,
          const SocketException('This might be socket exception'),
        );

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CommandFailure(CommandErrorType.network),
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
          'returns CommandFailure(CommandErrorType.unknown) on other'
          ' client exceptions and logs result', () async {
        mockClientException(
          client,
          Exception('This is not a socket exception'),
        );

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CommandFailure(CommandErrorType.unknown),
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
          'returns CommandFailure(CommandErrorType.authentication) when'
          ' response code is 401 and logs result', () async {
        mockClientPost(client, Response('', 401));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CommandFailure(CommandErrorType.authentication),
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
          'returns CommandFailure(CommandErrorType.forbiddenAccess) when'
          ' response code is 403 and logs result', () async {
        mockClientPost(client, Response('', 403));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CommandFailure(CommandErrorType.forbiddenAccess),
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
          'returns CommandFailure(CommandErrorType.unknown) for other'
          ' response codes and logs result', () async {
        mockClientPost(client, Response('', 404));

        final result = await cqrs.run(ExampleCommand());

        expect(
          result,
          const CommandFailure(CommandErrorType.unknown),
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
          'calls CqrsMiddleware.handleResult for each'
          ' middleware present', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.run(ExampleCommand());
        mockCqrsMiddlewareHandleResult(middleware, result);
        verifyNever(() => middleware.handleResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.run(ExampleCommand());
        mockCqrsMiddlewareHandleResult(middleware, result);
        verify(() => middleware.handleResult(result)).called(1);
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

        expect(result, const OperationSuccess<bool?>(true));

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

        expect(result, const OperationSuccess<bool?>(null));
      });

      test(
          'returns OperationFailure(CqrsError.unknown) on json decoding'
          ' failure and logs result', () async {
        mockClientPost(client, Response('true', 200));

        final result =
            await cqrs.perform(ExampleOperationFailingResultFactory());

        expect(
          result,
          const OperationFailure<bool>(OperationErrorType.unknown),
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
          'returns OperationFailure(CqrsError.network) on socket exception'
          ' and logs result', () async {
        mockClientException(
          client,
          const SocketException('This might be socket exception'),
        );

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const OperationFailure<bool?>(OperationErrorType.network),
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
          'returns OperationFailure(CqrsError.unknown) on client exception'
          ' and logs result', () async {
        final exception = Exception('This is not a socket exception');
        mockClientException(client, exception);

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const OperationFailure<bool?>(OperationErrorType.unknown),
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
          'returns OperationFailure(CqrsError.authentication) when response'
          ' code is 401 and logs result', () async {
        mockClientPost(client, Response('', 401));

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const OperationFailure<bool?>(OperationErrorType.authentication),
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
          'returns OperationFailure(CqrsError.forbiddenAccess) when response'
          ' code is 403 and logs result', () async {
        mockClientPost(client, Response('', 403));

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const OperationFailure<bool?>(OperationErrorType.forbiddenAccess),
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
          'returns OperationFailure(CqrsError.unknown) for other response'
          ' codes and logs result', () async {
        mockClientPost(client, Response('', 404));

        final result = await cqrs.perform(ExampleOperation());

        expect(
          result,
          const OperationFailure<bool?>(OperationErrorType.unknown),
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
          'calls CqrsMiddleware.handleResult for each'
          ' middleware present', () async {
        mockClientPost(client, Response('true', 200));

        var result = await cqrs.perform(ExampleOperation());
        mockCqrsMiddlewareHandleResult(middleware, result);
        verifyNever(() => middleware.handleResult(any()));

        cqrs.addMiddleware(middleware);
        result = await cqrs.perform(ExampleOperation());
        mockCqrsMiddlewareHandleResult(middleware, result);
        verify(() => middleware.handleResult(result)).called(1);
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

void mockCqrsMiddlewareHandleResult<T, E>(
  MockCqrsMiddleware middleware,
  CqrsMethodResult<T, E> result,
) {
  when(
    () => middleware.handleResult(result),
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
