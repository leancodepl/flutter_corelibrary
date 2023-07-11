import 'package:debug_page/src/models/log_record_format_extension.dart';
import 'package:debug_page/src/models/logs_summarizer.dart';
import 'package:logging/logging.dart';

class LoggerLogsSummarizer extends LogsSummarizer<LogRecord> {
  @override
  Future<String> summarize(List<LogRecord> logs) async {
    final buffer = StringBuffer();

    for (final logRecord in logs) {
      buffer.writeln(logRecord.format());
      buffer.writeln(LogsSummarizer.recordsDivider);
    }

    return buffer.toString();
  }
}
