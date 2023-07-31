import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:forms_generator/src/extensions/extensions.dart';
import 'package:forms_generator/src/models/models.dart';

/// {@template form_body_field_metadata}
/// A metadata model for a field in a form body.
/// {@endtemplate}
class FormBodyFieldMetadata {
  /// {@macro form_body_field_metadata}
  const FormBodyFieldMetadata({
    required this.fieldIdentifier,
    required this.formClassMetadata,
    this.genericTypeArguments = const {},
  });

  /// The name of the field to be used in the form body.
  ///
  /// ```
  /// MyFormBody(
  ///   age: AgeFormField(...)
  /// )
  /// ```
  /// means that the field `age` will be used in the form body.
  final SimpleIdentifier fieldIdentifier;

  /// The metadata for the form class being used.
  final ClientClassMetadata formClassMetadata;

  /// A [Map] of the relationships between the generic type arguments of the
  /// [formClassType] and the types assigned to those generics.
  ///
  /// ```
  /// class SomeFormField<A, B, C> extends FormField<A, B, C> {...}
  ///
  /// final myFormField = new SomeFormField<int, bool, String>(...);
  /// ```
  ///
  /// In this case, the [genericTypeArguments] of `myFormField` will be
  /// `{A: int, B: bool, C: String}`.
  final Map<TypeParameterElement, DartType> genericTypeArguments;

  DartType get _formClassType =>
      formClassMetadata.instanceType ?? formClassMetadata.baseType;

  /// Indicates if this form field extends the `FormField` class.
  bool get extendsFormField {
    return formClassMetadata.supertype != null &&
        formClassMetadata.supertype!.nonNullableDisplayString
            .startsWith(kFormFieldBaseClassName);
  }

  /// The non-nullable name of the `FormField` class instance.
  ///
  /// `class NameFormField extends FormField<String, String, NameFormFieldValidationError>`
  /// means that the class [formClassName] is `NameFormField`.
  String get formClassName {
    return _formClassType.potentiallyNullableDisplayString;
  }

  /// The generic type `R` in `FormField<R, T, E>`.
  ///
  /// If [extendsFormField] is `false`, this will return the [formClassMetadata]
  /// instance type or base type.
  DartType get rawValueType {
    if (!extendsFormField) {
      return _formClassType;
    }

    final resolved = formClassMetadata.instanceType!
        .asInstanceOf(formClassMetadata.supertype!.element)!;
    return resolved.typeArguments[0];
  }

  /// The generic type `T` in `FormField<R, T, E>`.
  ///
  /// If [extendsFormField] is `false`, this will return the [formClassMetadata]
  /// instance type or base type.
  DartType get valueType {
    if (!extendsFormField) {
      return _formClassType;
    }

    final resolved = formClassMetadata.instanceType!
        .asInstanceOf(formClassMetadata.supertype!.element)!;
    return resolved.typeArguments[1];
  }

  /// The generic type `E` in `FormField<R, T, E>`.
  ///
  /// If [extendsFormField] is `false`, this will return the [formClassMetadata]
  /// instance type or base type.
  DartType get errorType {
    if (!extendsFormField) {
      return _formClassType;
    }

    final resolved = formClassMetadata.instanceType!
        .asInstanceOf(formClassMetadata.supertype!.element)!;
    return resolved.typeArguments[2];
  }

  @override
  String toString() =>
      'FormBodyFieldMetadata(fieldIdentifier: $fieldIdentifier, formClassMetadata: $formClassMetadata, genericTypeArguments: $genericTypeArguments)';

  FormBodyFieldMetadata copyWith({
    SimpleIdentifier? fieldIdentifier,
    ClientClassMetadata? formClassMetadata,
    Map<TypeParameterElement, DartType>? genericTypeArguments,
  }) {
    return FormBodyFieldMetadata(
      fieldIdentifier: fieldIdentifier ?? this.fieldIdentifier,
      formClassMetadata: formClassMetadata ?? this.formClassMetadata,
      genericTypeArguments: genericTypeArguments ?? this.genericTypeArguments,
    );
  }
}
