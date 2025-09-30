import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

enum MockLibrary {
  flutter('flutter', 'material.dart', _flutterMock),
  bloc('bloc', 'bloc.dart', _blocMock),
  flutterBloc('flutter_bloc', 'flutter_bloc.dart', _flutterBlocMock);

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
}

const _flutterMock = '''
class Key {
  const Key(String _);
}

class Widget {
  const Widget();
}

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
