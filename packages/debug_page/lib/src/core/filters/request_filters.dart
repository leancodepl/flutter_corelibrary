import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';

class RequestStatusFilter implements Filter<RequestLogRecord> {
  const RequestStatusFilter({required this.desiredStatus});

  final RequestStatus desiredStatus;

  @override
  Future<bool> filter(RequestLogRecord requestLogRecord) async =>
      requestLogRecord.status == desiredStatus;
}

class RequestSearchFilter implements Filter<RequestLogRecord> {
  const RequestSearchFilter({
    required this.type,
    required this.phrase,
  });

  final RequestSearchType type;
  final String phrase;

  @override
  Future<bool> filter(RequestLogRecord requestLogRecord) async {
    bool? url;
    bool? body;

    final lowercasePhrase = phrase.toLowerCase();

    if ([RequestSearchType.url, RequestSearchType.all].contains(type)) {
      url = requestLogRecord.url
          .toString()
          .toLowerCase()
          .contains(lowercasePhrase);
    }

    if ([RequestSearchType.body, RequestSearchType.all].contains(type)) {
      if (requestLogRecord.responseBodyCompleter.isCompleted) {
        body = (await requestLogRecord.responseBodyCompleter.future)
            .toLowerCase()
            .contains(lowercasePhrase);
      }
    }

    return switch (type) {
      RequestSearchType.url => url ?? false,
      RequestSearchType.body => body ?? false,
      RequestSearchType.all when url == true || body == true => true,
      _ => false,
    };
  }
}
