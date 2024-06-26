extension ApplyExtension<T> on List<Filter<T>> {
  Future<List<T>> apply(List<T> source) async {
    // This is needed to ignore changes made to original list between
    // calculating criteriaMet and returning the final result
    final sourceCopy = [...source];

    final criteriaMet = await Future.wait(
      sourceCopy.map(
        (item) async {
          final f = await Future.wait(map((filter) => filter.filter(item)));
          return f.every((e) => e);
        },
      ),
    );

    return sourceCopy.indexed
        .where((e) => criteriaMet[e.$1])
        .map((e) => e.$2)
        .toList();
  }
}

abstract class Filter<T> {
  Future<bool> filter(T requestLogRecord);
}
