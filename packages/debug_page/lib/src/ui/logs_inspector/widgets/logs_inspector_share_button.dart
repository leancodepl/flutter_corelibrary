import 'package:debug_page/src/core/logger_listener.dart';
import 'package:debug_page/src/core/logging_http_client.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/share_request_log_dialog.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class LogsInspectorShareButton extends StatelessWidget {
  const LogsInspectorShareButton({
    super.key,
    required LoggingHttpClient loggingHttpClient,
    required LoggerListener loggerListener,
  })  : _loggingHttpClient = loggingHttpClient,
        _loggerListener = loggerListener;

  final LoggingHttpClient _loggingHttpClient;
  final LoggerListener _loggerListener;

  @override
  Widget build(BuildContext context) {
    return ShareButton(
      onPressed: () async {
        final String sharedData;
        final tabIndex = DefaultTabController.of(context).index;

        if (tabIndex == LogsInspectorTab.requests.index) {
          final sharingConfiguration = await showShareRequestLogDialog(context);
          if (sharingConfiguration == null) {
            return;
          }

          sharedData = await _loggingHttpClient.getSummary(
            sharingConfiguration,
          );
        } else if (tabIndex == LogsInspectorTab.logs.index) {
          sharedData = await _loggerListener.getSummary(
            LogSharingConfiguration(),
          );
        } else {
          throw StateError('Unknown tab');
        }

        Share.share(sharedData);
      },
    );
  }
}
