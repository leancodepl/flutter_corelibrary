abstract class LogGatherer<T> {
  Stream<List<T>> get logStream;
  List<T> get logs;
}
