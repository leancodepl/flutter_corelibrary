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

  /// The component's own class, for its outermost element: [name] in kebab
  /// case, so `SiteFooter` renders as `site-footer-<suffix>`.
  ///
  /// It begins with a letter or `_`, as the Dart name does, so it is a valid
  /// class name whatever the suffix starts with.
  ClassName get root => ClassName.scoped(_kebab(name), this);

  @override
  String toString() => 'ClassScope($name)';
}

/// [name] in kebab case: `SiteFooter` → `site-footer`, `HTMLView` →
/// `html-view`. A `$`, which a class name cannot hold unescaped, becomes `_`.
String _kebab(String name) =>
    name
        .replaceAllMapped(
          RegExp('([a-z0-9])([A-Z])|([A-Z])([A-Z][a-z])'),
          (match) =>
              match[1] != null
                  ? '${match[1]}-${match[2]}'
                  : '${match[3]}-${match[4]}',
        )
        .replaceAll(r'$', '_')
        .toLowerCase();
