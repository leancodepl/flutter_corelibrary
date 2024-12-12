import 'package:example/adaptive_svg_gen_image.dart';
import 'package:example/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:leancode_flutter_svg_adaptive_loader/leancode_flutter_svg_adaptive_loader.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'Assets created by SvgPicture(LeanCodeFlutterSvgAdaptiveLoader("asset_path"))'),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: _SvgPictureWithTitle(
                    text: 'XML-based foo',
                    svgPicture: SvgPicture(
                      FlutterSvgAdaptiveLoader('assets/foo.svg'),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _SvgPictureWithTitle(
                    text: 'Binary compiled foo',
                    svgPicture: SvgPicture(
                      FlutterSvgAdaptiveLoader(
                        'assets/foo_compiled.svg',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text('Assets created by SvgGenImage.adaptiveSvg()'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SvgPictureWithTitle(
                    text: 'XML-based foo',
                    svgPicture: Assets.foo.adaptiveSvg(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SvgPictureWithTitle(
                    text: 'Binary compiled foo',
                    svgPicture: Assets.fooCompiled.adaptiveSvg(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SvgPictureWithTitle extends StatelessWidget {
  const _SvgPictureWithTitle({
    required this.text,
    required this.svgPicture,
  });

  final String text;
  final Widget svgPicture;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text),
        const SizedBox(height: 8),
        svgPicture,
      ],
    );
  }
}
