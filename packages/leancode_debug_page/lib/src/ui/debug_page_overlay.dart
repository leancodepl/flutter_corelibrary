import 'package:flutter/material.dart';
import 'package:leancode_debug_page/leancode_debug_page.dart';
import 'package:leancode_debug_page/src/ui/debug_page_button.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/logs_inspector.dart';

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
        if (_controller.showEntryButton)
          DebugPageButton(controller: _controller),
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
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
              ),
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
