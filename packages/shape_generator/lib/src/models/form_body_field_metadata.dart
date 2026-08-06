import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/models/models.dart';

/// {@template form_body_field_metadata}
/// A metadata model for a field in a form body.
/// {@endtemplate}
class FormBodyFieldMetadata {
  /// {@macro form_body_field_metadata}
  const FormBodyFieldMetadata({
    required this.fieldName,
    required this.formClassMetadata,
    required this.wrapperExpression,
    this.isCustomWrapper = false,
    this.isFactoryParameterRequired = false,
    this.genericTypeArguments = const {},
  });

  /// The name of the field to be used in the form body.
  ///
  /// ```dart
  /// MyFormBody(
  ///   age: AgeFormField(...)
  /// )
  /// ```
  /// means that the field `age` will be used in the form body.
  final String fieldName;

  /// The metadata for the form class being used.
  final ClientClassMetadata formClassMetadata;

  /// The expression used to construct the form field in the generated factory.
  final String wrapperExpression;

  /// Indicates whether the wrapper is explicitly provided by user code.
  final bool isCustomWrapper;

  /// Whether the user-facing factory parameter is required.
  final bool isFactoryParameterRequired;

  /// A [Map] of the relationships between the generic type arguments of the
  /// [formClassType] and the types assigned to those generics.
  ///
  /// ```dart
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
        formClassMetadata.supertype!.nonNullableDisplayString.startsWith(
          kFormFieldBaseClassName,
        );
  }

  /// The non-nullable name of the `FormField` class instance.
  ///
  // ignore: lines_longer_than_80_chars
  /// `class NameFormField extends FormField<String, String, NameFormFieldValidationError>`
  /// means that the class [formClassName] is `NameFormField`.
  String get formClassName {
    if (genericTypeArguments.isNotEmpty &&
        formClassMetadata.typeParameters.isNotEmpty) {
      final typeArguments = genericTypeArguments.values
          .map((type) => type.getDisplayString())
          .join(', ');
      final baseName = formClassMetadata.name.split('<').first;
      return '$baseName<$typeArguments>';
    }
    return _formClassType.potentiallyNullableDisplayString;
  }

  /// The generic type `R` in `FormField<R, T, E>`.
  ///
  /// If [extendsFormField] is `false`, this will return the [formClassMetadata]
  /// instance type or base type.
  DartType get rawValueType {
    if (extendsFormField && genericTypeArguments.length == 1) {
      return genericTypeArguments.values.first;
    }
    if (!extendsFormField) {
      return _formClassType;
    }

    final resolved = formClassMetadata.instanceType!.asInstanceOf(
      formClassMetadata.supertype!.element,
    )!;
    return resolved.typeArguments[0];
  }

  /// The generic type `T` in `FormField<R, T, E>`.
  ///
  /// If [extendsFormField] is `false`, this will return the [formClassMetadata]
  /// instance type or base type.
  DartType get valueType {
    if (extendsFormField && genericTypeArguments.length == 1) {
      return genericTypeArguments.values.first;
    }
    if (!extendsFormField) {
      return _formClassType;
    }

    final resolved = formClassMetadata.instanceType!.asInstanceOf(
      formClassMetadata.supertype!.element,
    )!;
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

    final resolved = formClassMetadata.instanceType!.asInstanceOf(
      formClassMetadata.supertype!.element,
    )!;
    return resolved.typeArguments[2];
  }

  @override
  String toString() =>
      'FormBodyFieldMetadata('
      'fieldName: $fieldName, '
      'wrapperExpression: $wrapperExpression, '
      'isCustomWrapper: $isCustomWrapper, '
      'formClassMetadata: $formClassMetadata, '
      'genericTypeArguments: $genericTypeArguments'
      ')';

  /// Creates a copy of this [FormBodyFieldMetadata] with the given fields
  /// replaced with the new values.
  FormBodyFieldMetadata copyWith({
    String? fieldName,
    ClientClassMetadata? formClassMetadata,
    String? wrapperExpression,
    bool? isCustomWrapper,
    Map<TypeParameterElement, DartType>? genericTypeArguments,
  }) {
    return FormBodyFieldMetadata(
      fieldName: fieldName ?? this.fieldName,
      formClassMetadata: formClassMetadata ?? this.formClassMetadata,
      wrapperExpression: wrapperExpression ?? this.wrapperExpression,
      isCustomWrapper: isCustomWrapper ?? this.isCustomWrapper,
      genericTypeArguments: genericTypeArguments ?? this.genericTypeArguments,
    );
  }
}
