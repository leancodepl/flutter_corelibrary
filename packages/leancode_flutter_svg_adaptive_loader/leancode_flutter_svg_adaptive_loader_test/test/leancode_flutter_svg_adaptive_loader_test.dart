import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_flutter_svg_adaptive_loader/leancode_flutter_svg_adaptive_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Finds and renders xml-based svg asset', (tester) async {
    final loader = FlutterSvgAdaptiveLoader(
      'assets/foo.svg',
      packageName: 'leancode_flutter_svg_adaptive_loader_test',
      assetBundle: rootBundle,
    );

    final widget = SvgPicture(loader);

    await tester.pumpWidget(widget);

    final picture = find.byWidget(widget);

    expect(picture, findsOneWidget);
  });

  testWidgets('Finds and renders compiled binary svg asset', (tester) async {
    final loader = FlutterSvgAdaptiveLoader(
      'assets/foo_compiled.svg',
      packageName: 'leancode_flutter_svg_adaptive_loader_test',
      assetBundle: rootBundle,
    );

    final widget = SvgPicture(loader);

    await tester.pumpWidget(widget);

    final picture = find.byWidget(widget);

    expect(picture, findsOneWidget);
  });
}
