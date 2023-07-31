/// {@template form_body}
/// A container for a collection of form fields.
///
/// Used in conjunction with the `forms_generator` package to generate a form
/// from a set of [FormField]s.
///
/// The generic type [E] represents the type of the error container when
/// calling [validate].
/// {@endtemplate}
///
/// {@template form_body_sample}
/// ```dart
/// @GenerateFormBody()
/// abstract class RegistrationFormBody
///   extends FormBody<RegistrationFormErrors>
///   with _$RegistrationFormBodyFields {
///   factory RegistrationFormBody({
///     required String username,
///     required String age,
///   }) {
///     return _$RegistrationFormBody(
///       username: GenericFormField(
///         value: username,
///         isRequired: true,
///       ),
///       age: AgeFormField(
///         value: age,
///       ),
///     );
///   }
///
///   const RegistrationFormBody._();
/// }
/// ```
/// {@endtemplate}
abstract class FormBody<E extends FormErrors<dynamic>> {
  /// {@macro form_body}
  const FormBody();

  /// Validates all the fields in this form.
  E validate();
}

/// {@template form_errors}
/// A container for a collection of form field validation errors.
///
/// Used in conjunction with the `forms_generator` package to generate the
/// errors for a [FormBody].
///
/// The generic type [E] represents the type of the [FormBody] container that
/// this error represents.
///
/// Any classes extending [FormErrors] must override the [errors] getter and
/// provide it all the errors that occurred during validation.
///
/// Use [hasErrors] to determine if there are any errors in this container.
/// {@endtemplate}
/// {@macro form_body_sample}
abstract class FormErrors<E extends FormBody<dynamic>> {
  /// {@macro form_errors}
  const FormErrors();

  /// All validation errors in this container.
  List<Object?> get errors;

  /// Indicates whether this container has any validation errors.
  bool get isNotEmpty => errors.any((error) => error != null);

  /// Indicates whether this container has no validation errors.
  bool get isEmpty => !isNotEmpty;
}
