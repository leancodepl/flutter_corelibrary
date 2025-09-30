import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

enum MockLibrary {
  flutter('flutter', 'material.dart', _flutterMock),
  bloc('bloc', 'bloc.dart', _blocMock),
  flutterBloc('flutter_bloc', 'flutter_bloc.dart', _flutterBlocMock),
  sliverTools('sliver_tools', 'sliver_tools.dart', _sliverToolsMock);

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
