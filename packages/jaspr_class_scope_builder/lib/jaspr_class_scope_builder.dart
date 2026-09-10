/// Build-time class-name scopes for `jaspr_class_scope`.
library;

import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/class_scope_builder.dart';
import 'package:jaspr_class_scope_builder/src/class_scope_check_builder.dart';

export 'src/class_scope_builder.dart';
export 'src/class_scope_check_builder.dart';
export 'src/suffix.dart';

/// Writes the scope of every component annotated with `@scopedCss`.
Builder classScopeBuilder(BuilderOptions options) => const ClassScopeBuilder();

/// Fails the build when two of those scopes took one suffix.
Builder classScopeCheckBuilder(BuilderOptions options) =>
    const ClassScopeCheckBuilder();
