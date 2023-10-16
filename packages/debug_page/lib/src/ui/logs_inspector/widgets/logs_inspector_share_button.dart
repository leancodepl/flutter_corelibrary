import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/core/logs_summarizers/logger_logs_summarizer.dart';
import 'package:debug_page/src/core/logs_summarizers/request_logs_summarizer.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/show_share_request_log_dialog.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class LogsInspectorShareButton extends StatelessWidget {
  const LogsInspectorShareButton({
    super.key,
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

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

          final logs = _controller.requestsLogs;

          sharedData = await RequestsLogsSummarizer(
            configuration: sharingConfiguration,
          ).summarize(logs);
        } else if (tabIndex == LogsInspectorTab.logs.index) {
          final logs = _controller.loggerLogs;
          sharedData = await LoggerLogsSummarizer().summarize(logs);
        } else {
          throw StateError('Unknown tab');
        }

        await Share.share(sharedData);
      },
    );
  }
}
