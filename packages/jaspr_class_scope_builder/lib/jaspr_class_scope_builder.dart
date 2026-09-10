/// Build-time class-name scopes for `jaspr_class_scope`.
library;

import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/class_scope_builder.dart';

export 'src/class_scope_builder.dart';

/// The entry point `build.yaml` names.
Builder classScopeBuilder(BuilderOptions options) => const ClassScopeBuilder();
