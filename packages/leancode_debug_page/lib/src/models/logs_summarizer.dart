abstract class LogsSummarizer<T> {
  const LogsSummarizer();

  static final recordsDivider = '_' * 50;

  Future<String> summarize(List<T> logs);
}
