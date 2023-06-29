import 'package:bloc/bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Provides a [Cubit] or a [Bloc] current state. Forces [HookWidget] rebuild on
/// state changed.
S useBlocState<S>(BlocBase<S> bloc) {
  return useStream(
    bloc.stream,
    initialData: bloc.state,
    preserveState: false,
  ).data as S;
}
