import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/logger_listener.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class DebugPageOverlay extends StatefulWidget {
  const DebugPageOverlay({
    super.key,
    required this.loggingHttpClient,
    required this.child,
  });

  final LoggingHttpClient loggingHttpClient;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _DebugPageOverlayState();
}

class _DebugPageOverlayState extends State<DebugPageOverlay> {
  _DebugPageOverlayState() : _loggerListener = LoggerListener();

  final LoggerListener _loggerListener;
  bool showDebugScreen = false;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();

    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 4,
      onPhoneShake: () {
        setState(() {
          showDebugScreen = true;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _loggerListener.dispose();
    _shakeDetector?.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // The default value for alignment is AlignmentDirectional.topStart, which
      // needs a Directionality ancestor, which we do not want, hence
      // Alignment.center
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Align(
          alignment: Alignment.bottomLeft,
          child: GestureDetector(
            onTap: () => setState(() {
              showDebugScreen = true;
            }),
            child: Container(
              width: 48,
              height: 48,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ),
        if (showDebugScreen)
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: LogsInspector(
              loggingHttpClient: widget.loggingHttpClient,
              loggerListener: _loggerListener,
              onBackButtonClicked: () {
                setState(() {
                  showDebugScreen = false;
                });
              },
            ),
          ),
      ],
    );
  }
}
