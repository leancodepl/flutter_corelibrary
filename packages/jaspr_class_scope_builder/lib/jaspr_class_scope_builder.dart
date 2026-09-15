/// Build-time class-name scopes for `jaspr_class_scope`.
library;

import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/class_scope_builder.dart';
import 'package:jaspr_class_scope_builder/src/class_scope_check_builder.dart';
import 'package:jaspr_class_scope_builder/src/scopes_manifest_builder.dart';

export 'src/class_scope_builder.dart';
export 'src/class_scope_check_builder.dart';
export 'src/scopes_manifest_builder.dart';

/// Writes the scope of every component annotated with `@scopedCss`.
Builder classScopeBuilder(BuilderOptions options) => const ClassScopeBuilder();

/// Lists a package's scopes for the check to read.
Builder scopesManifestBuilder(BuilderOptions options) =>
    const ScopesManifestBuilder();

/// Fails the build when two of those scopes end up the same.
Builder classScopeCheckBuilder(BuilderOptions options) =>
    const ClassScopeCheckBuilder();
