import 'package:debug_page/src/models/logs_summarizer.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/show_share_request_log_dialog.dart';

class RequestsLogsSummarizer extends LogsSummarizer<RequestLogRecord> {
  const RequestsLogsSummarizer({required this.configuration});

  final RequestSharingConfiguration configuration;

  @override
  Future<String> summarize(List<RequestLogRecord> logs) async {
    final buffer = StringBuffer();

    for (final log in logs) {
      buffer
        ..writeln(await log.toSummary(configuration))
        ..writeln(LogsSummarizer.recordsDivider);
    }

    return buffer.toString();
  }
}
