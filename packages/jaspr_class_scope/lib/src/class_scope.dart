import 'package:jaspr_class_scope/src/class_name.dart';

/// The locally scoped class names of one component.
final class ClassScope {
  /// The scope of [name]'s class names, which all end with [suffix].
  const ClassScope(this.name, this.suffix);

  /// The component this scope belongs to.
  final String name;

  /// What makes this scope's class names local to it.
  final String suffix;

  /// The class [local] of this scope's component.
  ClassName call(String local) => ClassName.scoped(local, this);

  @override
  String toString() => 'ClassScope($name)';
}
