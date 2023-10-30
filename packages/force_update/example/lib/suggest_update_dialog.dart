import 'package:flutter/material.dart';
import 'package:force_update/force_update.dart';

class SuggestUpdateDialog extends StatelessWidget {
  const SuggestUpdateDialog({
    super.key,
    required ForceUpdate forceUpdate,
  }) : _forceUpdate = forceUpdate;

  final ForceUpdate _forceUpdate;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dialog(
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
                        onPressed: ForceUpdateGuardController.of(context)
                            .hideSuggestDialog,
                        child: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _forceUpdate.openStore,
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
    );
  }
}
