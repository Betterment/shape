import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template generate_form_body}
/// An annotation for the `forms` package.
///
/// Annotating a class with this annotation will flag it as needing to be
/// processed by the `forms_generator` code generator.
/// {@endtemplate}
@immutable
class GenerateFormBody extends Equatable {
  /// {@macro generate_form_body}
  const GenerateFormBody({
    bool? generateFormErrors,
  }) : generateFormErrors = generateFormErrors ?? true;

  /// Indicates if `forms_generator` should generate a `FormErrors` class.
  final bool generateFormErrors;

  @override
  List<Object> get props => [generateFormErrors];
}
