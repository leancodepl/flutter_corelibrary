import 'package:debug_page/src/models/request_log_record.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareRequestLogDialog extends StatefulWidget {
  const ShareRequestLogDialog({
    super.key,
    required this.requestLog,
  });

  final RequestLogRecord requestLog;

  @override
  State<StatefulWidget> createState() {
    return _ShareRequestLogDialogState();
  }
}

class _ShareRequestLogDialogState extends State<ShareRequestLogDialog> {
  _ShareRequestLogDialogState();

  bool includeResponse = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              tristate: false,
              title: const Text('Include response'),
              value: includeResponse,
              onChanged: (value) => setState(
                () => includeResponse = value ?? false,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final summary = await widget.requestLog.toSummary(
                    includeResponse,
                  );

                  await Share.share(summary);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
