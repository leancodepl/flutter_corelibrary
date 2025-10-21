import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  final middleware = ExampleCqrsMiddleware();

  group('CqrsMiddleware', () {
    group('handleQueryResult', () {
      test('returns the same result by default', () async {
        const resultIn = QuerySuccess(true, rawData: 'true');
        final resultOut = await middleware.handleQueryResult(resultIn);
        expect(resultIn, resultOut);
      });
    });

    group('handleCommandResult', () {
      test('returns the same result by default', () async {
        const resultIn = CommandSuccess();
        final resultOut = await middleware.handleCommandResult(resultIn);
        expect(resultIn, resultOut);
      });
    });

    group('handleOperationResult', () {
      test('returns the same result by default', () async {
        const resultIn = OperationSuccess(true);
        final resultOut = await middleware.handleOperationResult(resultIn);
        expect(resultIn, resultOut);
      });
    });
  });
}

class ExampleCqrsMiddleware extends CqrsMiddleware {}
