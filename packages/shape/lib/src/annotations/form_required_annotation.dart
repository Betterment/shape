import 'package:meta/meta.dart';

/// {@template field_required_annotation}
/// Marks a form body factory parameter as required for validation.
///
/// Use on optional parameters that should still be wrapped in a
/// [GenericFormField] with `isRequired: true`.
/// {@endtemplate}
@immutable
class FieldRequired {
  /// {@macro field_required_annotation}
  const FieldRequired();
}
