import 'package:flutter/material.dart';
import 'package:leancode_force_update/leancode_force_update.dart';

class SuggestUpdateDialog extends StatelessWidget {
  const SuggestUpdateDialog({
    super.key,
    required ForceUpdateController forceUpdateController,
  }) : _forceUpdateController = forceUpdateController;

  final ForceUpdateController _forceUpdateController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ColoredBox(
        color: Colors.black.withOpacity(0.5),
        child: Stack(
          children: [
            GestureDetector(
              onTap: _forceUpdateController.hideSuggestDialog,
              behavior: HitTestBehavior.translucent,
            ),
            Dialog(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Update suggested'),
                      const SizedBox(height: 8),
                      const Text(
                        'A new version is available, please update the app',
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _forceUpdateController.hideSuggestDialog,
                              child: const Text('Skip'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _forceUpdateController.openStore,
                              child: const Text('Update'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
