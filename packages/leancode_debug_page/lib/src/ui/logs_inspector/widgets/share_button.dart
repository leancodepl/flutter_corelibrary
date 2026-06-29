import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.onPressed,
  });

  final void Function(Rect sharePositionOrigin) onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final box = context.findRenderObject()! as RenderBox;
        onPressed(box.localToGlobal(Offset.zero) & box.size);
      },
      child: const Icon(Icons.share),
    );
  }
}
