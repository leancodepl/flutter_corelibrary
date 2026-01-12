import 'package:cached_cqrs/src/queries.dart';
import 'package:cached_cqrs/src/state.dart';
import 'package:cached_query/cached_query.dart' as cq;
import 'package:cqrs/cqrs.dart';

class CachedCqrs implements Cqrs {
  CachedCqrs({
    required Cqrs baseCqrs,
    cq.CachedQuery? cache,
  })  : _baseCqrs = baseCqrs,
        _cache = cache;

  final Cqrs _baseCqrs;
  final cq.CachedQuery? _cache;

  @override
  void addMiddleware(CqrsMiddleware middleware) {
    _baseCqrs.addMiddleware(middleware);
  }

  @override
  Future<QueryResult<T>> get<T>(
    Query<T> query, {
    Map<String, String> headers = const {},
    cq.QueryConfig? config,
    T? initialData,
  }) async {
    final result = await CqrsQuery(
      key: query,
      cqrs: this,
      config: config,
      cache: _cache,
      initialData: initialData,
    ).result.then(QueryState.new);

    return switch (result.status) {
      cq.QueryStatus.success => QuerySuccess(result.data as T),
      cq.QueryStatus.error => QueryFailure(result.error!),
      _ => throw StateError('Result is in invalid state: ${result.status}'),
    };
  }

  void invalidateQuery(Query<Object?> query) {
    cq.CachedQuery.instance.invalidateCache(key: query);
  }

  @override
  Future<OperationResult<T>> perform<T>(
    Operation<T> operation, {
    Map<String, String> headers = const {},
    Iterable<Query<Object?>>? queriesToInvalidate,
  }) async {
    final result = await _baseCqrs.perform(operation, headers: headers);
    if (result.isSuccess) {
      for (final query in queriesToInvalidate ?? Iterable.empty()) {
        invalidateQuery(query);
      }
    }
    return result;
  }

  @override
  void removeMiddleware(CqrsMiddleware middleware) {
    _baseCqrs.removeMiddleware(middleware);
  }

  @override
  Future<CommandResult> run(
    Command command, {
    Map<String, String> headers = const {},
    Iterable<Query<Object?>>? queriesToInvalidate,
  }) async {
    final result = await _baseCqrs.run(command, headers: headers);
    if (result.isSuccess) {
      for (final query in queriesToInvalidate ?? Iterable.empty()) {
        invalidateQuery(query);
      }
    }
    return result;
  }
}
