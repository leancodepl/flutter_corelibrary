import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:flutter/material.dart';

class DebugPageOverlay extends StatelessWidget {
  const DebugPageOverlay({
    super.key,
    required DebugPageController controller,
    required this.child,
  }) : _controller = controller;

  final DebugPageController _controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // The default value for alignment is AlignmentDirectional.topStart, which
      // needs a Directionality ancestor, which we do not want, hence
      // Alignment.center
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        child,
        Align(
          alignment: Alignment.bottomLeft,
          child: GestureDetector(
            onTap: () => _controller.visible.value = true,
            child: Container(
              width: 48,
              height: 48,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _controller.visible,
          builder: (context, visible, child) {
            if (!visible || child == null) {
              return const SizedBox();
            }

            return child;
          },
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: LogsInspector(
              controller: _controller,
              onBackButtonClicked: () => _controller.visible.value = false,
            ),
          ),
        ),
      ],
    );
  }
}
