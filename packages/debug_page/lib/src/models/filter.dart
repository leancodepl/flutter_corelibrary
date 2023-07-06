extension ApplyExtension<T> on List<Filter<T>> {
  List<T> apply(List<T> source) {
    return source
        .where((item) => every((filter) => filter.filter(item)))
        .toList();
  }
}

abstract class Filter<T> {
  bool filter(T requestLogRecord);
}
