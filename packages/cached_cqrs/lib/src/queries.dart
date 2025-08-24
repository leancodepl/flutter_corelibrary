import 'package:cached_cqrs/src/state.dart';
import 'package:cached_query/cached_query.dart' as cq;
import 'package:cqrs/cqrs.dart';

/// {@macro query}
class CqrsQuery<T, TQuery extends Query<T>> implements cq.Query<T> {
  CqrsQuery({
    required TQuery key,
    required Cqrs cqrs,
    this.headers = const {},
    cq.OnQueryErrorCallback<T>? onError,
    cq.OnQuerySuccessCallback<T>? onSuccess,
    T? initialData,
    cq.QueryConfig? config,
    cq.CachedQuery? cache,
  }) : _delegate = cq.Query(
          key: key,
          queryFn: () async {
            final result = await cqrs.get(key, headers: headers);
            return switch (result) {
              QuerySuccess(:final data) => data,
              QueryFailure(:final error) => throw error,
            };
          },
          onError: onError,
          onSuccess: onSuccess,
          initialData: initialData,
          config: config,
          cache: cache,
        );

  final cq.Query<T> _delegate;

  Map<String, String> headers;

  @override
  Future<void> close() => _delegate.close();

  @override
  cq.QueryConfig get config => _delegate.config;

  @override
  void deleteQuery({bool deleteStorage = false}) =>
      _delegate.deleteQuery(deleteStorage: deleteStorage);

  @override
  bool get hasListener => _delegate.hasListener;

  @override
  void invalidateQuery() => _delegate.invalidateQuery();

  @override
  String get key => _delegate.key;

  @override
  Future<QueryState<T>> refetch() => _delegate.refetch().then(QueryState.new);

  @override
  Future<QueryState<T>> get result => _delegate.result.then(QueryState.new);

  @override
  bool get stale => _delegate.stale;

  @override
  QueryState<T> get state => QueryState(_delegate.state);

  @override
  Stream<QueryState<T>> get stream => _delegate.stream.map(QueryState.new);

  @override
  TQuery get unencodedKey => _delegate.unencodedKey as TQuery;

  @override
  void update(cq.UpdateFunc<T> updateFn) => _delegate.update(updateFn);
}

class InfiniteCqrsQuery<T, TQuery extends Query<T>>
    implements cq.InfiniteQuery<T, TQuery> {
  /// {@macro infiniteQuery}
  InfiniteCqrsQuery({
    required TQuery key,
    required Cqrs cqrs,
    required cq.GetNextArg<T, TQuery> getNextArg,
    this.headers = const {},
    List<TQuery>? prefetchPages,
    cq.QueryConfig? config,
    List<T>? initialData,
    bool forceRevalidateAll = false,
    bool revalidateAll = false,
    cq.OnQueryErrorCallback<T>? onError,
    cq.OnQuerySuccessCallback<T>? onSuccess,
    cq.CachedQuery? cache,
  }) : _delegate = cq.InfiniteQuery(
          key: key,
          queryFn: (arg) async {
            final result = await cqrs.get(arg, headers: headers);
            return switch (result) {
              QuerySuccess(:final data) => data,
              QueryFailure(:final error) => throw error,
            };
          },
          getNextArg: getNextArg,
          prefetchPages: prefetchPages,
          config: config,
          initialData: initialData,
          forceRevalidateAll: forceRevalidateAll,
          revalidateAll: revalidateAll,
          onError: onError,
          onSuccess: onSuccess,
          cache: cache,
        );

  final cq.InfiniteQuery<T, TQuery> _delegate;

  Map<String, String> headers;

  /// Closes the stream and therefore starts the delete timer.
  @override
  Future<void> close() => _delegate.close();

  /// The config for this specific query.
  @override
  cq.QueryConfig get config => _delegate.config;

  /// Delete the query and query key from cache
  @override
  void deleteQuery({bool deleteStorage = false}) =>
      _delegate.deleteQuery(deleteStorage: deleteStorage);

  /// Whether the query stream has any listeners.
  @override
  bool get hasListener => _delegate.hasListener;

  /// Mark query as stale.
  ///
  /// Will force a fetch next time the query is accessed.
  @override
  void invalidateQuery() => _delegate.invalidateQuery();

  /// The key used to store and access the query. Encoded using jsonEncode.
  ///
  /// This is created by calling jsonEncode on the passed dynamic key.
  @override
  String get key => _delegate.key;

  /// Refetch the query immediately.
  ///
  /// Returns the updated [InfiniteQueryState] and will notify the [stream].
  @override
  Future<InfiniteQueryState<T>> refetch() =>
      _delegate.refetch().then(InfiniteQueryState.new);

  /// Get the result of calling the queryFn.
  ///
  /// If [result] is used when the [stream] has no listeners [result] will start
  /// the delete timer once complete. For full caching functionality see [stream].
  @override
  Future<InfiniteQueryState<T>> get result =>
      _delegate.result.then(InfiniteQueryState.new);

  /// Whether the current query is marked as stale and therefore requires a
  /// refetch.
  @override
  bool get stale => _delegate.stale;

  /// The current state of the query.
  @override
  InfiniteQueryState<T> get state => InfiniteQueryState(_delegate.state);

  /// Stream the state of the query.
  ///
  /// When the state is updated either by a mutation or a new query [stream]
  /// will be notified.
  @override
  Stream<InfiniteQueryState<T>> get stream =>
      _delegate.stream.map(InfiniteQueryState.new);

  /// The original key.
  @override
  TQuery get unencodedKey => _delegate.unencodedKey as TQuery;

  /// Update the current [InfiniteQuery] data.
  ///
  /// The [updateFn] passes the current query data and must return new data of
  /// type [T]
  @override
  void update(cq.UpdateFunc<List<T>> updateFn) => _delegate.update(updateFn);

  /// Whether the Query should always refetch all pages, not just check the first
  /// for changes.
  @override
  bool get forceRevalidateAll => _delegate.forceRevalidateAll;

  /// Get the next page in an [InfiniteCqrsQuery] and cache the result.
  @override
  Future<InfiniteQueryState<T>?> getNextPage() => _delegate
      .getNextPage()
      .then((state) => state == null ? null : InfiniteQueryState(state));

  /// True if there are no more pages available to fetch.
  ///
  /// Calculated using [cq.GetNextArg], if it has returned null then this is true.
  @override
  bool hasReachedMax() => _delegate.hasReachedMax();

  /// Get the last page in the [InfiniteQueryState.data]
  @override
  T? get lastPage => _delegate.lastPage;

  /// If the fist page has changed then revalidate all pages. Defaults to false.
  @override
  bool get revalidateAll => _delegate.revalidateAll;
}
