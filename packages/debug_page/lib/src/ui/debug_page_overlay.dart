import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:floating_chat_button/floating_chat_button.dart';
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
        if (_controller.showEntryButton)
          SafeArea(
            child: Overlay(
              clipBehavior: Clip.none,
              initialEntries: [
                OverlayEntry(
                  builder: (context) => FloatingChatButton(
                    onTap: (_) => _controller.visible.value = true,
                    shouldPutWidgetInCircle: false,
                    chatIconWidget: _controller.showEntryButton
                        ? FloatingActionButton(
                            backgroundColor: Colors.amber.shade700,
                            splashColor: Colors.amber.shade900,
                            onPressed: () => _controller.visible.value = true,
                            child: const Icon(
                              Icons.bug_report_outlined,
                              size: 36,
                              color: Colors.black,
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ],
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
