extension ApplyExtension<T> on List<Filter<T>> {
  Future<List<T>> apply(List<T> source) async {
    final criteriaMet = await Future.wait(
      source.map(
        (item) async {
          final f = await Future.wait(map((filter) => filter.filter(item)));
          return f.every((e) => e);
        },
      ),
    );

    return source.indexed
        .where((e) => criteriaMet[e.$1])
        .map((e) => e.$2)
        .toList();

    // return source
    //     .where((item) => every((filter) => filter.filter(item)))
    //     .toList();
  }
}

abstract class Filter<T> {
  Future<bool> filter(T requestLogRecord);
}
