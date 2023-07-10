import 'package:flutter/foundation.dart';

@immutable
abstract class SummaryConfiguration {}

abstract class LogGatherer<T, S extends SummaryConfiguration> {
  static final recordsSeparator = '-' * 50;

  Stream<List<T>> get logStream;
  List<T> get logs;

  Future<String> getSummary(S configuration);
}
