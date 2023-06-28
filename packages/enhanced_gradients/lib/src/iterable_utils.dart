/// Zips two iterables together into an iterable of pairs of source iterables'
/// elements. Zipping stops once either iterable runs out of elements.
Iterable<(A, B)> zip2<A, B>(
  Iterable<A> iterableA,
  Iterable<B> iterableB,
) sync* {
  final iteratorA = iterableA.iterator;
  final iteratorB = iterableB.iterator;
  while (iteratorA.moveNext() && iteratorB.moveNext()) {
    yield (iteratorA.current, iteratorB.current);
  }
}

/// Extension providing extra helpers on [Iterable].
extension IterableExtension<T> on Iterable<T> {
  /// Yields all pairs of subsequent elements. If the source iterable has less
  /// than two elements, the resulting iterable is empty.
  Iterable<(T, T)> pairwise() sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return;
    }
    var previous = iterator.current;
    while (iterator.moveNext()) {
      final next = iterator.current;
      yield (previous, next);
      previous = next;
    }
  }
}
