import 'package:debug_page/debug_page.dart';
import 'package:flutter/material.dart';

class DebugPageButton extends StatefulWidget {
  const DebugPageButton({
    super.key,
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  State<StatefulWidget> createState() => DebugPageButtonState();
}

class DebugPageButtonState extends State<DebugPageButton> {
  Alignment _alignment = Alignment.bottomRight;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) {
              final Size(:height, :width) = MediaQuery.sizeOf(context);
              final horizontalCenter = width / 2;
              final verticalCenter = height / 2;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: _alignment,
                    child: Draggable(
                      feedback: Align(
                        alignment: _alignment,
                        child: _Button(widget._controller),
                      ),
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
                      child: _Button(widget._controller),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button(this._controller);

  final DebugPageController _controller;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _controller.visible.value = true,
      child: const Icon(Icons.bug_report),
    );
  }
}
