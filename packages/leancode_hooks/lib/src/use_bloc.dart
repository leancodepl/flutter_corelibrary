import 'package:bloc/bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Provides a [Bloc] without having to use BlocProvider.
B useBloc<B extends Bloc<S, E>, S, E>(
  B Function() create, [
  List<Object> keys = const [],
]) {
  final bloc = useMemoized(create, keys);

  useEffect(() => bloc.close, [bloc]);

  return bloc;
}

/// Provides a [Cubit] without having to use BlocProvider.
C useCubit<C extends Cubit<S>, S>(
  C Function() create, [
  List<Object> keys = const [],
]) {
  final cubit = useMemoized(create, keys);

  useEffect(() => cubit.close, [cubit]);

  return cubit;
}
