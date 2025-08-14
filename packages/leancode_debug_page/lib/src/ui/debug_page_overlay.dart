import 'package:flutter/material.dart';
import 'package:leancode_debug_page/leancode_debug_page.dart';
import 'package:leancode_debug_page/src/ui/debug_page_button.dart';

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
        ValueListenableBuilder(
          valueListenable: _controller.isOpen,
          builder: (context, isOpen, child) {
            if (_controller.showEntryButton && !isOpen) {
              return child!;
            }

            return const SizedBox();
          },
          child: DebugPageButton(controller: _controller),
        ),
      ],
    );
  }
}
