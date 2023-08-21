import 'package:bloc/bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Provides [Cubit]'s or [Bloc]'s current state. Forces [HookWidget] to
/// rebuild on state change.
B useBloc<B extends BlocBase<Object?>>(
  B Function() create, [
  List<Object?> keys = const [],
]) {
  final bloc = useMemoized(create, keys);

  useEffect(() => bloc.close, [bloc]);

  return bloc;
}
