import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

enum MockLibrary {
  bloc('bloc', {'lib/bloc.dart': _blocMock}),
  flutterBloc('flutter_bloc', {'lib/flutter_bloc.dart': _flutterBlocMock}),
  sliverTools('sliver_tools', {'lib/sliver_tools.dart': _sliverToolsMock}),
  flutterHooks('flutter_hooks', {'lib/flutter_hooks.dart': _flutterHooksMock}),
  hooksRiverpod('hooks_riverpod', {
    'lib/hooks_riverpod.dart': _hooksRiverpodMock,
  });

  const MockLibrary(this.name, this.files);

  final String name;
  final Map<String, String> files;
}

extension AddMockLibraryX on AnalysisRuleTest {
  void addMocks(Iterable<MockLibrary> mocks) {
    for (final mock in mocks) {
      final package = newPackage(mock.name);
      for (final MapEntry(key: path, value: content) in mock.files.entries) {
        package.addFile(path, content);
      }
    }
  }
}

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

BuildContext useContext() {}

T useMemoized<T>(
  T Function() valueBuilder, [
  List<Object?> keys = const <Object>[],
]) {}
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
