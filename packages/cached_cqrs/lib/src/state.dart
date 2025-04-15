import 'package:cached_query/cached_query.dart' as cq;
import 'package:cqrs/cqrs.dart';

extension type QueryState<T>._(cq.QueryState<T> state)
    implements cq.QueryState<T> {
  QueryState(this.state) {
    if (state.error != null && state.error is! QueryError) {
      throw ArgumentError(
          'QueryState only supports states with errors of type QueryError. Received error type was ${state.error.runtimeType}');
    }
  }

  QueryError? get error => switch (state.error) {
        null => null,
        QueryError e => e,
        _ => throw state.error,
      };
}

extension type InfiniteQueryState<T>._(cq.InfiniteQueryState<T> state)
    implements cq.InfiniteQueryState<T> {
  InfiniteQueryState(this.state) {
    if (state.error != null && state.error is! QueryError) {
      throw ArgumentError(
          'InfiniteQueryState only supports states with errors of type QueryError. Received error type was ${state.error.runtimeType}');
    }
  }

  QueryError? get error => switch (state.error) {
        null => null,
        QueryError e => e,
        _ => throw state.error,
      };
}
