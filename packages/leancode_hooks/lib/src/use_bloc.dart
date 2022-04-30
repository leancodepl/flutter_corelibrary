import 'package:bloc/bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Provides a [Cubit] or a [Bloc] that is automatically disposed without having
/// to use BlocProvider.
B useBloc<B extends BlocBase<Object?>>(
  B Function() create, [
  List<Object?> keys = const [],
]) {
  final bloc = useMemoized(create, keys);

  useEffect(() => bloc.close, [bloc]);

  return bloc;
}
