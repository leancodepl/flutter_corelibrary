import 'package:debug_page/src/entry/debug_page.dart';
import 'package:flutter/material.dart';

final debugPageOverlayState = GlobalKey<_DebugPageOverlayState>();

class DebugPageOverlay extends StatelessWidget {
  const DebugPageOverlay({
    super.key,
    required this.debugPage,
    required this.child,
  });

  final DebugPage debugPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DebugPageOverlay(
      key: debugPageOverlayState,
      debugPage: debugPage,
      child: child,
    );
  }
}

class _DebugPageOverlay extends StatefulWidget {
  const _DebugPageOverlay({
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

class _DebugPageOverlayState extends State<_DebugPageOverlay> {
  OverlayEntry? overlayEntry;

  void _createOverlayEntry() {
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Visibility(
          visible: !widget.debugPage.shown,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: () async {
                // TODO: Figure out how to close all other overlays temporarily
                // and insert them back after DebugPage is popped

                await widget.debugPage.show();
              },
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
      Overlay.of(context).insert(overlayEntry!);
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
    overlayEntry?.remove();
    overlayEntry = null;

    super.dispose();
  }
}
