// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tokens.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Token {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String? parameter) tagOpen,
    required TResult Function(String name) tagClose,
    required TResult Function(String content) text,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String? parameter)? tagOpen,
    TResult? Function(String name)? tagClose,
    TResult? Function(String content)? text,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String? parameter)? tagOpen,
    TResult Function(String name)? tagClose,
    TResult Function(String content)? text,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TokenTagOpen value) tagOpen,
    required TResult Function(_TokenTagClose value) tagClose,
    required TResult Function(_TokenTagText value) text,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TokenTagOpen value)? tagOpen,
    TResult? Function(_TokenTagClose value)? tagClose,
    TResult? Function(_TokenTagText value)? text,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TokenTagOpen value)? tagOpen,
    TResult Function(_TokenTagClose value)? tagClose,
    TResult Function(_TokenTagText value)? text,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenCopyWith<$Res> {
  factory $TokenCopyWith(Token value, $Res Function(Token) then) =
      _$TokenCopyWithImpl<$Res, Token>;
}

/// @nodoc
class _$TokenCopyWithImpl<$Res, $Val extends Token>
    implements $TokenCopyWith<$Res> {
  _$TokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_TokenTagOpenCopyWith<$Res> {
  factory _$$_TokenTagOpenCopyWith(
          _$_TokenTagOpen value, $Res Function(_$_TokenTagOpen) then) =
      __$$_TokenTagOpenCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, String? parameter});
}

/// @nodoc
class __$$_TokenTagOpenCopyWithImpl<$Res>
    extends _$TokenCopyWithImpl<$Res, _$_TokenTagOpen>
    implements _$$_TokenTagOpenCopyWith<$Res> {
  __$$_TokenTagOpenCopyWithImpl(
      _$_TokenTagOpen _value, $Res Function(_$_TokenTagOpen) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? parameter = freezed,
  }) {
    return _then(_$_TokenTagOpen(
      null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      freezed == parameter
          ? _value.parameter
          : parameter // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_TokenTagOpen implements _TokenTagOpen {
  const _$_TokenTagOpen(this.name, [this.parameter]);

  @override
  final String name;
  @override
  final String? parameter;

  @override
  String toString() {
    return 'Token.tagOpen(name: $name, parameter: $parameter)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TokenTagOpen &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.parameter, parameter) ||
                other.parameter == parameter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, parameter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TokenTagOpenCopyWith<_$_TokenTagOpen> get copyWith =>
      __$$_TokenTagOpenCopyWithImpl<_$_TokenTagOpen>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String? parameter) tagOpen,
    required TResult Function(String name) tagClose,
    required TResult Function(String content) text,
  }) {
    return tagOpen(name, parameter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String? parameter)? tagOpen,
    TResult? Function(String name)? tagClose,
    TResult? Function(String content)? text,
  }) {
    return tagOpen?.call(name, parameter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String? parameter)? tagOpen,
    TResult Function(String name)? tagClose,
    TResult Function(String content)? text,
    required TResult orElse(),
  }) {
    if (tagOpen != null) {
      return tagOpen(name, parameter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TokenTagOpen value) tagOpen,
    required TResult Function(_TokenTagClose value) tagClose,
    required TResult Function(_TokenTagText value) text,
  }) {
    return tagOpen(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TokenTagOpen value)? tagOpen,
    TResult? Function(_TokenTagClose value)? tagClose,
    TResult? Function(_TokenTagText value)? text,
  }) {
    return tagOpen?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TokenTagOpen value)? tagOpen,
    TResult Function(_TokenTagClose value)? tagClose,
    TResult Function(_TokenTagText value)? text,
    required TResult orElse(),
  }) {
    if (tagOpen != null) {
      return tagOpen(this);
    }
    return orElse();
  }
}

abstract class _TokenTagOpen implements Token {
  const factory _TokenTagOpen(final String name, [final String? parameter]) =
      _$_TokenTagOpen;

  String get name;
  String? get parameter;
  @JsonKey(ignore: true)
  _$$_TokenTagOpenCopyWith<_$_TokenTagOpen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_TokenTagCloseCopyWith<$Res> {
  factory _$$_TokenTagCloseCopyWith(
          _$_TokenTagClose value, $Res Function(_$_TokenTagClose) then) =
      __$$_TokenTagCloseCopyWithImpl<$Res>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$_TokenTagCloseCopyWithImpl<$Res>
    extends _$TokenCopyWithImpl<$Res, _$_TokenTagClose>
    implements _$$_TokenTagCloseCopyWith<$Res> {
  __$$_TokenTagCloseCopyWithImpl(
      _$_TokenTagClose _value, $Res Function(_$_TokenTagClose) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_$_TokenTagClose(
      null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_TokenTagClose implements _TokenTagClose {
  const _$_TokenTagClose(this.name);

  @override
  final String name;

  @override
  String toString() {
    return 'Token.tagClose(name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TokenTagClose &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TokenTagCloseCopyWith<_$_TokenTagClose> get copyWith =>
      __$$_TokenTagCloseCopyWithImpl<_$_TokenTagClose>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String? parameter) tagOpen,
    required TResult Function(String name) tagClose,
    required TResult Function(String content) text,
  }) {
    return tagClose(name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String? parameter)? tagOpen,
    TResult? Function(String name)? tagClose,
    TResult? Function(String content)? text,
  }) {
    return tagClose?.call(name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String? parameter)? tagOpen,
    TResult Function(String name)? tagClose,
    TResult Function(String content)? text,
    required TResult orElse(),
  }) {
    if (tagClose != null) {
      return tagClose(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TokenTagOpen value) tagOpen,
    required TResult Function(_TokenTagClose value) tagClose,
    required TResult Function(_TokenTagText value) text,
  }) {
    return tagClose(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TokenTagOpen value)? tagOpen,
    TResult? Function(_TokenTagClose value)? tagClose,
    TResult? Function(_TokenTagText value)? text,
  }) {
    return tagClose?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TokenTagOpen value)? tagOpen,
    TResult Function(_TokenTagClose value)? tagClose,
    TResult Function(_TokenTagText value)? text,
    required TResult orElse(),
  }) {
    if (tagClose != null) {
      return tagClose(this);
    }
    return orElse();
  }
}

abstract class _TokenTagClose implements Token {
  const factory _TokenTagClose(final String name) = _$_TokenTagClose;

  String get name;
  @JsonKey(ignore: true)
  _$$_TokenTagCloseCopyWith<_$_TokenTagClose> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_TokenTagTextCopyWith<$Res> {
  factory _$$_TokenTagTextCopyWith(
          _$_TokenTagText value, $Res Function(_$_TokenTagText) then) =
      __$$_TokenTagTextCopyWithImpl<$Res>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$_TokenTagTextCopyWithImpl<$Res>
    extends _$TokenCopyWithImpl<$Res, _$_TokenTagText>
    implements _$$_TokenTagTextCopyWith<$Res> {
  __$$_TokenTagTextCopyWithImpl(
      _$_TokenTagText _value, $Res Function(_$_TokenTagText) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_$_TokenTagText(
      null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_TokenTagText implements _TokenTagText {
  const _$_TokenTagText(this.content);

  @override
  final String content;

  @override
  String toString() {
    return 'Token.text(content: $content)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TokenTagText &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TokenTagTextCopyWith<_$_TokenTagText> get copyWith =>
      __$$_TokenTagTextCopyWithImpl<_$_TokenTagText>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String? parameter) tagOpen,
    required TResult Function(String name) tagClose,
    required TResult Function(String content) text,
  }) {
    return text(content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String? parameter)? tagOpen,
    TResult? Function(String name)? tagClose,
    TResult? Function(String content)? text,
  }) {
    return text?.call(content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String? parameter)? tagOpen,
    TResult Function(String name)? tagClose,
    TResult Function(String content)? text,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TokenTagOpen value) tagOpen,
    required TResult Function(_TokenTagClose value) tagClose,
    required TResult Function(_TokenTagText value) text,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TokenTagOpen value)? tagOpen,
    TResult? Function(_TokenTagClose value)? tagClose,
    TResult? Function(_TokenTagText value)? text,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TokenTagOpen value)? tagOpen,
    TResult Function(_TokenTagClose value)? tagClose,
    TResult Function(_TokenTagText value)? text,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }
}

abstract class _TokenTagText implements Token {
  const factory _TokenTagText(final String content) = _$_TokenTagText;

  String get content;
  @JsonKey(ignore: true)
  _$$_TokenTagTextCopyWith<_$_TokenTagText> get copyWith =>
      throw _privateConstructorUsedError;
}
