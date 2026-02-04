extension IterableExtensions<T> on Iterable<T> {
  Iterable<(T, U)> zip<U>(Iterable<U> other) sync* {
    final iter1 = iterator;
    final iter2 = other.iterator;

    while (iter1.moveNext() && iter2.moveNext()) {
      yield (iter1.current, iter2.current);
    }
  }

  T? firstWhereOrNull(bool Function(T) test) => where(test).firstOrNull;
}
