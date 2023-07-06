import 'package:flutter/foundation.dart';

@immutable
abstract class SummaryConfiguration {}

abstract class LogGatherer<T, S extends SummaryConfiguration> {
  Stream<List<T>> get logStream;
  List<T> get logs;

  Future<String> getSummary(S configuration);
}
