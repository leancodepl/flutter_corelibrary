import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

enum MockLibrary {
  flutter('flutter', 'material.dart', _flutterMock),
  bloc('bloc', 'bloc.dart', _blocMock),
  flutterBloc('flutter_bloc', 'flutter_bloc.dart', _flutterBlocMock),
  sliverTools('sliver_tools', 'sliver_tools.dart', _sliverToolsMock),
  flutterHooks('flutter_hooks', 'flutter_hooks.dart', _flutterHooksMock),
  hooksRiverpod('hooks_riverpod', 'hooks_riverpod.dart', _hooksRiverpodMock);

  const MockLibrary(this.name, this.importFile, this.content);

  final String name;
  final String importFile;
  final String content;

  String get rootPath => '/packages/$name';
  String get mockFilePath => '$rootPath/lib/$importFile';
}

extension AddMockLibraryX on AnalysisRuleTest {
  void addMocks(List<MockLibrary> libraries) {
    for (final lib in libraries) {
      newFile(lib.mockFilePath, lib.content);
    }

    final builder = PackageConfigFileBuilder();
    for (final lib in libraries) {
      builder.add(name: lib.name, rootPath: convertPath(lib.rootPath));
    }
    writeTestPackageConfig(builder);
  }

  void addAnalysisOptions({String applicationPrefix = 'Lncd'}) {
    final existingAnalysisOptions = resourceProvider
        .getFile(join(testPackageRootPath, 'analysis_options.yaml'))
        .readAsStringSync();
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
$existingAnalysisOptions

leancode_lint:
  application_prefix: $applicationPrefix
''');
  }
}

const _flutterMock = '''
class Key {
  const Key(String _);
}

class BuildContext {}

class Widget {
  const Widget({Key? key});
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  Widget build(BuildContext context);
}

abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});

  State createState();
}

abstract class State<T extends StatefulWidget> extends StatelessWidget {}

class Container extends Widget {
  Container({
    Key? key,
    EdgeInsets? margin,
    EdgeInsets? padding,
    AlignmentGeometry? alignment,
    Color? color,
    Widget? child,
  });
}

class SizedBox extends Widget {
  const SizedBox();
}

class Padding extends Widget {
  const Padding({
    EdgeInsets? padding,
    Widget? child,
  });
}

class SliverToBoxAdapter extends Widget {
  const SliverToBoxAdapter();
}

class Builder extends StatelessWidget {
  const Builder({super.key, required this.builder});

  final Widget Function(BuildContext context) builder;
}

enum Axis { horizontal, vertical }

class Flex extends StatelessWidget {
  const Flex({
    required Axis direction,
    required List<Widget> children,
  });
}

class Column extends Flex {
  const Column({required super.children}) : super(direction: Axis.vertical);
}

class Row extends Flex {
  const Row({required super.children}) : super(direction: Axis.horizontal);
}

class Wrap extends StatelessWidget {
  const Wrap({List<Widget> children = const []});
}

class SliverChildListDelegate {
  SliverChildListDelegate(List<Widget> children);
}

class SliverList extends StatelessWidget {
  SliverList.list({required List<Widget> children});
}

class SliverMainAxisGroup extends StatelessWidget {
  const SliverMainAxisGroup({required List<Widget> slivers});
}

class SliverCrossAxisGroup extends StatelessWidget {
  const SliverCrossAxisGroup({required List<Widget> slivers});
}

class SliverToBoxAdapter extends StatelessWidget {
  const SliverToBoxAdapter({Widget? child});
}

class EdgeInsets {
  const EdgeInsets.all(double _);
}

class Colors {
  static const red = Color(0xFFFF0000);
}

class ValueNotifier<T> {
  T get value => throw UnimplementedError();
}

class TextEditingController {}

class PageController {}

class PageView extends StatelessWidget {
  PageView({PageController? controller});
}

abstract class AlignmentGeometry {
  const AlignmentGeometry();
}

class Alignment extends AlignmentGeometry {
  const Alignment(double x, double y);

  static const center = Alignment(0, 0);
  static const centerLeft = Alignment(-1, 0);
  static const topCenter = Alignment(0, -1);
  static const bottomCenter = Alignment(0, 1);
}

class Align extends StatelessWidget {
  const Align({
    AlignmentGeometry alignment = Alignment.center,
    Widget? child,
  });
}
''';

const _blocMock = '''
abstract class Cubit<State> extends BlocBase<State> {
  Cubit(State initialState) : super(initialState);
}
''';

const _flutterBlocMock = '''
export 'package:bloc/bloc.dart';
''';

const _sliverToolsMock = '''
import 'package:flutter/material.dart';

class MultiSliver extends StatelessWidget {
  MultiSliver({required List<Widget> children});
}
''';

const _flutterHooksMock = '''
import 'package:flutter/material.dart';

void useAutomaticKeepAlive() {}

ValueNotifier<T> useState<T>(T initialData) {}

TextEditingController useTextEditingController() {}

PageController usePageController() {}

class HookWidget extends StatelessWidget {
  const HookWidget({super.key});
}

class HookBuilder extends HookWidget {
  const HookBuilder({required Widget Function(BuildContext context) builder});
}
''';

const _hooksRiverpodMock = '''
import 'package:flutter/material.dart';

class WidgetRef {}

abstract class ConsumerWidget extends StatefulWidget {
  Widget build(BuildContext context, WidgetRef ref);

  @override
  State<ConsumerWidget> createState() => throw UnimplementedError();
}

abstract class HookConsumerWidget extends ConsumerWidget {
  const HookConsumerWidget({super.key});
}

typedef ConsumerBuilder =
    Widget Function(BuildContext context, WidgetRef ref, Widget? child);

class HookConsumer extends HookConsumerWidget {
  const HookConsumer({required ConsumerBuilder builder});
}
''';
