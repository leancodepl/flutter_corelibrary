import 'package:debug_page/src/core/log_gatherer.dart';
import 'package:flutter/material.dart';

class RequestSharingConfiguration implements SummaryConfiguration {
  const RequestSharingConfiguration({required this.includeResponse});

  final bool includeResponse;
}

Future<RequestSharingConfiguration?> showShareRequestLogDialog(
    BuildContext context) {
  return showDialog<RequestSharingConfiguration>(
    context: context,
    builder: (context) => const _ShareRequestLogDialog(),
  );
}

class _ShareRequestLogDialog extends StatefulWidget {
  const _ShareRequestLogDialog();

  @override
  State<StatefulWidget> createState() {
    return _ShareRequestLogDialogState();
  }
}

class _ShareRequestLogDialogState extends State<_ShareRequestLogDialog> {
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
                  Navigator.pop(
                    context,
                    RequestSharingConfiguration(
                      includeResponse: includeResponse,
                    ),
                  );
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
