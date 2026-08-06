/// {@template form_body}
/// A container for a collection of form fields.
///
/// Used in conjunction with the `shape_generator` package to generate a form
/// from a set of [FormField]s.
/// {@endtemplate}
///
/// {@template form_body_sample}
/// ```dart
/// @GenerateFormBody()
/// abstract class RegistrationFormBody extends FormBody {
///   const RegistrationFormBody._();
///
///   factory RegistrationFormBody({
///     @FieldRequired() String username,
///     @FieldRequired() String age,
///   }) =>
///       _$RegistrationFormBody(username: username, age: age);
/// }
/// ```
/// {@endtemplate}
abstract class FormBody {
  /// {@macro form_body}
  const FormBody();

  /// Validates all the fields in this form.
  FormErrors validate();
}

/// {@template form_errors}
/// A container for a collection of form field validation errors.
///
/// Used in conjunction with the `shape_generator` package to generate the
/// errors for a [FormBody].
///
/// Any classes extending [FormErrors] must override the [errors] getter and
/// provide it all the errors that occurred during validation.
///
/// Use [hasErrors] to determine if there are any errors in this container.
/// {@endtemplate}
abstract class FormErrors {
  /// {@macro form_errors}
  const FormErrors();

  /// All validation errors in this container.
  List<Object?> get errors;

  /// Indicates whether this container has any validation errors.
  bool get isNotEmpty => errors.any((error) => error != null);

  /// Indicates whether this container has no validation errors.
  bool get isEmpty => !isNotEmpty;
}
