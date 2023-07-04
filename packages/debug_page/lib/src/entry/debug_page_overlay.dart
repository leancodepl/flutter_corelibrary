import 'package:debug_page/src/entry/debug_page.dart';
import 'package:flutter/material.dart';

class DebugPageOverlay extends StatefulWidget {
  const DebugPageOverlay({
    super.key,
    required this.debugPage,
    required this.child,
  });

  final DebugPage debugPage;
  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _DebugPageOverlayState();
  }
}

class _DebugPageOverlayState extends State<DebugPageOverlay> {
  OverlayEntry? _overlayEntry;

  void _createOverlayEntry() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Visibility(
          visible: !widget.debugPage.shown,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: widget.debugPage.show,
              child: Container(
                width: 48,
                height: 48,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  @override
  void initState() {
    super.initState();
    _createOverlayEntry();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    super.dispose();
  }
}
