import 'package:flutter/material.dart';
import 'package:leancode_debug_page/leancode_debug_page.dart';

class DebugPageButton extends StatelessWidget {
  const DebugPageButton({
    super.key,
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _DraggableFloatingButton(controller: _controller),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DraggableFloatingButton extends StatefulWidget {
  const _DraggableFloatingButton({
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  State<StatefulWidget> createState() => _DraggableFloatingButtonState();
}

class _DraggableFloatingButtonState extends State<_DraggableFloatingButton> {
  _DraggableFloatingButtonState();

  Alignment _alignment = Alignment.bottomRight;

  @override
  Widget build(BuildContext context) {
    final Size(:height, :width) = MediaQuery.sizeOf(context);
    final horizontalCenter = width / 2;
    final verticalCenter = height / 2;

    final floatingActionButton = FloatingActionButton(
      onPressed: () => widget._controller.visible.value = true,
      child: const Icon(Icons.bug_report),
    );

    return Align(
      alignment: _alignment,
      child: Draggable(
        feedback: floatingActionButton,
        onDragEnd: (details) {
          final Offset(:dx, :dy) = details.offset;
          final top = dy < verticalCenter;
          final right = dx > horizontalCenter;

          final newAlignment = switch ((top, right)) {
            (true, true) => Alignment.topRight,
            (true, false) => Alignment.topLeft,
            (false, true) => Alignment.bottomRight,
            (false, false) => Alignment.bottomLeft,
          };

          if (newAlignment != _alignment) {
            setState(() {
              _alignment = newAlignment;
            });
          }
        },
        childWhenDragging: const SizedBox(),
        child: floatingActionButton,
      ),
    );
  }
}
