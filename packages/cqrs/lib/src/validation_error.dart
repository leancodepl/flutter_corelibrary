import 'package:equatable/equatable.dart';

/// A validation error.
class ValidationError extends Equatable {
  /// Creates a [ValidationError] from [code], [message], and [propertyName].
  const ValidationError(this.code, this.message, this.propertyName);

  /// Creates a [ValidationError] from JSON.
  ValidationError.fromJson(Map<String, dynamic> json)
      : code = json['ErrorCode'] as int,
        message = json['ErrorMessage'] as String,
        propertyName = json['PropertyName'] as String;

  /// Code of the validation error.
  final int code;

  /// Message describing the validation error.
  final String message;

  /// Path to the property which caused the error.
  final String propertyName;

  /// Serializes this [ValidationError] to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'ErrorCode': code,
        'ErrorMessage': message,
        'PropertyName': propertyName,
      };

  @override
  String toString() => '[$propertyName] $code: $message';

  @override
  List<Object?> get props => [code, message, propertyName];
}
