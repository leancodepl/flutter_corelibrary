import 'package:debug_page/src/models/log_record_format_extension.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/show_share_request_log_dialog.dart';
import 'package:logging/logging.dart';

abstract class LogsSummarizer<T> {
  const LogsSummarizer();

  Future<String> summarize(List<T> logs);
}

// TODO: Split

class RequestsLogsSummarizer extends LogsSummarizer<RequestLogRecord> {
  const RequestsLogsSummarizer({required this.configuration});

  final RequestSharingConfiguration configuration;

  @override
  Future<String> summarize(List<RequestLogRecord> logs) async {
    final buffer = StringBuffer();

    for (final log in logs) {
      buffer.writeln(await log.toSummary(configuration));
      buffer.writeln('_' * 50);
    }

    return buffer.toString();
  }
}

class LoggerLogsSummarizer extends LogsSummarizer<LogRecord> {
  @override
  Future<String> summarize(List<LogRecord> logs) async {
    final buffer = StringBuffer();

    for (final logRecord in logs) {
      buffer.writeln(logRecord.format());
      buffer.writeln('_' * 50);
    }

    return buffer.toString();
  }
}
