/// {@template form_field}
/// A container for a single form field that can be validated.
///
/// The [rawValue] property is the raw input of the form field, usually a
/// `String`. The [value] property is the parsed value of the field, and will
/// be of type [T].
///
/// Calling the [validate] method will validate the field and return an error of
/// type [E] if the field is invalid. If the field is valid, it will return
/// `null`.
///
/// When [R] and [T] are the same, prefer [SimpleFormField].
///
/// ```dart
/// enum UsernameValidationError { empty, invalid }
///
/// class UsernameField
///   extends SimpleFormField<String, UsernameValidationError> {
///
///   const UsernameField(super.rawValue, {this.isRequired = true});
///
///   final bool isRequired;
///
///   @override
///   UsernameValidationError? validate() {
///     if (rawValue.isEmpty) {
///       return UsernameValidationError.empty;
///     } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(rawValue)) {
///       return UsernameValidationError.invalid;
///     } else {
///       return null;
///     }
///   }
/// }
/// ```
/// {@endtemplate}
abstract class FormField<R, T, E> {
  /// {@macro form_field}
  const FormField(this.rawValue);

  /// The raw value of the field, usually a `String`.
  final R rawValue;

  /// The parsed value of this field.
  T get value;

  /// Validates the current [value] of this field.
  ///
  /// If the field is invalid, an error of type [E] will be returned. If the
  /// field is valid, `null` will be returned.
  E? validate();
}

/// A [FormField] where the raw and parsed value types are the same.
typedef SimpleFormField<T, E> = FormField<T, T, E>;
