import 'package:flutter/material.dart';
import 'package:leancode_force_update/leancode_force_update.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    super.key,
    required ForceUpdateController forceUpdateController,
  }) : _forceUpdateController = forceUpdateController;

  final ForceUpdateController _forceUpdateController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: DefaultTextStyle(
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Update required'),
                    const SizedBox(height: 8),
                    const Text(
                      'To continue using the app, you have to update it',
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _forceUpdateController.openStore,
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
