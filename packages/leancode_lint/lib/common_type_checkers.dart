import 'package:custom_lint_builder/custom_lint_builder.dart';

extension TypeCheckers on Never {
  // dart
  static const iterable = TypeChecker.fromUrl('dart:core#Iterable');

  // equatable
  static const equatable = TypeChecker.fromName(
    'Equatable',
    packageName: 'equatable',
  );
  static const equatableMixin = TypeChecker.fromName(
    'EquatableMixin',
    packageName: 'equatable',
  );

  // flutter
  static const statelessWidget = TypeChecker.fromName(
    'StatelessWidget',
    packageName: 'flutter',
  );
  static const state = TypeChecker.fromName('State', packageName: 'flutter');
  static const column = TypeChecker.fromName('Column', packageName: 'flutter');
  static const row = TypeChecker.fromName('Row', packageName: 'flutter');
  static const wrap = TypeChecker.fromName('Wrap', packageName: 'flutter');
  static const flex = TypeChecker.fromName('Flex', packageName: 'flutter');
  static const sliverList = TypeChecker.fromName(
    'SliverList',
    packageName: 'flutter',
  );
  static const sliverMainAxisGroup = TypeChecker.fromName(
    'SliverMainAxisGroup',
    packageName: 'flutter',
  );
  static const sliverCrossAxisGroup = TypeChecker.fromName(
    'SliverCrossAxisGroup',
    packageName: 'flutter',
  );
  static const sliverChildListDelegate = TypeChecker.fromName(
    'SliverChildListDelegate',
    packageName: 'flutter',
  );

  static const multiSliver = TypeChecker.fromName(
    'MultiSliver',
    packageName: 'sliver_tools',
  );

  // hooks
  static const hookWidget = TypeChecker.fromName(
    'HookWidget',
    packageName: 'flutter_hooks',
  );
  static const hookBuilder = TypeChecker.fromName(
    'HookBuilder',
    packageName: 'flutter_hooks',
  );
  static const hookConsumer = TypeChecker.fromName(
    'HookConsumer',
    packageName: 'hooks_riverpod',
  );
  static const hookConsumerWidget = TypeChecker.fromName(
    'HookConsumerWidget',
    packageName: 'hooks_riverpod',
  );

  // bloc
  static const cubit = TypeChecker.fromName('Cubit', packageName: 'bloc');
  static const bloc = TypeChecker.fromName('Bloc', packageName: 'bloc');
  static const blocBase = TypeChecker.fromName('BlocBase', packageName: 'bloc');
  static const blocPresentation = TypeChecker.fromName(
    'BlocPresentationMixin',
    packageName: 'bloc_presentation',
  );
}
