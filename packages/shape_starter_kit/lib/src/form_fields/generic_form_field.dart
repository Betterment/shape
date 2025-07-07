import 'package:shape/shape.dart';

/// A set of generic validation errors.
///
/// Includes:
/// - `missing`: The field is missing when it is required. (Note that any
///   non-null String is not considered missing, even when it is empty.)
enum GenericValidationError {
  /// The field is missing when it is required. (Note that any non-null String
  /// is not considered missing, even when it is empty.)
  missing,
}

/// {@template generic_form_field}
/// A general purpose form field that can be used for any value.
///
/// If [isRequired] is `true`, the field will be considered invalid if the
/// provided [rawValue] is `null`. By default, fields are not required.
///
/// The [value] is equals to the provided [rawValue] (unchanged).
///
/// ```dart
/// final field = GenericFormField<String?>('Hello, world!');
/// print(field.validate()); // null
///
/// final field2 = GenericFormField<String?>(null, isRequired: true);
/// print(field2.validate()); // GenericValidationError.missing
/// ```
/// {@endtemplate}
class GenericFormField<T> extends FormField<T, T, GenericValidationError> {
  /// {@macro generic_form_field}
  const GenericFormField(super.rawValue, {this.isRequired = false});

  @override
  T get value => rawValue;

  /// Indicates whether this field is required.
  ///
  /// If set to `true`, the field will be considered invalid if the provided
  /// [rawValue] is `null`.
  final bool isRequired;

  @override
  GenericValidationError? validate() {
    if (rawValue == null && isRequired) {
      return GenericValidationError.missing;
    } else {
      return null;
    }
  }
}
