import 'package:bloc/bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Provides [Cubit]'s or [Bloc]'s current state. Forces [HookWidget] to
/// rebuild on state change.
S useBlocState<S>(BlocBase<S> bloc) {
  return useStream(
    bloc.stream,
    initialData: bloc.state,
    preserveState: false,
  ).data as S;
}
