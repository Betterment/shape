import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/generators/generators.dart';
import 'package:shape_generator/src/models/models.dart';

/// {@template form_body_generator}
/// The code generator responsible for generating form bodies.
/// {@endtemplate}
class FormBodyGenerator with SourceGenerator {
  /// {@macro form_body_generator}
  FormBodyGenerator({
    required this.enclosingClassMetadata,
    required this.generatedClassNames,
    required this.fields,
  });

  /// The metadata for the enclosing class.
  final ClientClassMetadata enclosingClassMetadata;

  /// The names for newly generated classes.
  final GeneratedClassNames generatedClassNames;

  /// The metadata for the fields of the form body.
  final List<FormBodyFieldMetadata> fields;

  String _getValue(FormBodyFieldMetadata field) {
    final name = field.fieldName;
    if (!field.extendsFormField) {
      return name;
    } else {
      return '$name.value';
    }
  }

  String _getRawValue(FormBodyFieldMetadata field) {
    final name = field.fieldName;
    if (!field.extendsFormField) {
      return name;
    } else {
      return '$name.rawValue';
    }
  }

  @override
  void write(SourceBuffer buffer) {
    final constructorArguments = fields
        .map(
          (field) =>
              field.isCustomWrapper ? field.fieldName : field.wrapperExpression,
        )
        .join(', ');

    buffer
      ..writeComment(
        'Form Body "${generatedClassNames.generatedFormBodyClassName}"',
      )
      ..writeImmutableAnnotation()
      ..writeClassDeclarationStart(
        name: generatedClassNames.generatedFormBodyClassName,
        extendedClass: generatedClassNames.formBodyClassName,
      )
      ..writeFactoryConstructorBody(
        className: generatedClassNames.generatedFormBodyClassName,
        parameters: [
          for (final field in fields)
            FunctionParameter(
              type: field.isCustomWrapper
                  ? field.formClassName
                  : field.rawValueType.potentiallyNullableDisplayString,
              name: field.fieldName,
              isRequired: field.isFactoryParameterRequired,
            ),
        ],
        body:
            'return ${generatedClassNames.generatedFormBodyClassName}._('
            '$constructorArguments,'
            ');',
      )
      ..writeClassConstructor(
        className: generatedClassNames.generatedFormBodyClassName,
        constructorName: '_',
        parameters: [
          for (final field in fields)
            FunctionParameter(
              type: field.formClassName,
              name: '_${field.fieldName}',
            ),
        ],
        useConstConstructor: false,
        useNamedParameters: false,
        supertypeConstructorName: '_',
      );

    for (final field in fields) {
      buffer
        ..writeClassField(
          type: field.formClassName,
          name: '_${field.fieldName}',
          isFinal: true,
          isOverride: true,
        )
        ..writeClassGetter(
          type: field.valueType.potentiallyNullableDisplayString,
          name: field.fieldName,
          value: '_${_getValue(field)}',
          isOverride: true,
        );
    }

    final enclosingClassValidateMethod = enclosingClassMetadata.methods
        .cast<ClientClassMethodMetadata?>()
        .firstWhere(
          (method) => method?.name == kValidateMethodName,
          orElse: () => null,
        );
    final enclosingClassOverridesValidateMethod =
        enclosingClassValidateMethod != null &&
        !enclosingClassValidateMethod.isAbstract;

    if (!enclosingClassOverridesValidateMethod) {
      final validationFields = fields
          .where((f) => f.extendsFormField)
          .map((f) => f.fieldName);
      buffer.writeSingleReturnFunction(
        returnType: generatedClassNames.generatedFormErrorsClassName,
        functionName: kValidateMethodName,
        returnValue:
            '${generatedClassNames.generatedFormErrorsClassName}'
            '(${validationFields.map((f) => '$f: _$f.validate(),').join()})',
        isOverride: true,
      );
    }

    buffer
      ..writeClassGetter(
        type: generatedClassNames.generatedCopyWithClassName,
        name: 'copyWith',
        value: '${generatedClassNames.generatedCopyWithImplClassName}(this)',
        isOverride: true,
      )
      ..writeEqualityOperators(
        className: generatedClassNames.generatedFormBodyClassName,
        equalityFields: [for (final field in fields) '_${_getRawValue(field)}'],
      )
      ..writeClassDeclarationEnd()
      ..writeComment(
        '''Copy With Interface "${generatedClassNames.generatedCopyWithClassName}"''',
      )
      ..writeClassDeclarationStart(
        name: generatedClassNames.generatedCopyWithClassName,
        isAbstract: true,
      )
      ..writeBodylessFunction(
        returnType: generatedClassNames.formBodyClassName,
        functionName: 'call',
        parameters: [
          for (final field in fields)
            FunctionParameter(
              type: _copyWithParameterType(field),
              name: field.fieldName,
              isRequired: false,
            ),
        ],
      )
      ..writeClassDeclarationEnd()
      ..writeComment(
        'Copy With Implementation '
        '"${generatedClassNames.generatedCopyWithImplClassName}"',
      )
      ..writeClassDeclarationStart(
        name: generatedClassNames.generatedCopyWithImplClassName,
        implementedInterfaces: [generatedClassNames.generatedCopyWithClassName],
      )
      ..writeClassConstructor(
        className: generatedClassNames.generatedCopyWithImplClassName,
        parameters: [
          FunctionParameter(
            type: generatedClassNames.generatedFormBodyClassName,
            name: '_instance',
          ),
        ],
      )
      ..writeClassField(
        type: generatedClassNames.generatedFormBodyClassName,
        name: '_instance',
      )
      ..writeStaticConstClassField(name: '_defaultValue', value: 'Object()');

    final fieldNames = fields.map((f) => f.fieldName);
    final copyWithFields = [
      for (final field in fields) _copyWithArgument(field),
    ];

    buffer
      ..writeSingleReturnFunction(
        returnType: generatedClassNames.formBodyClassName,
        functionName: 'call',
        parameters: [
          for (final field in fieldNames)
            FunctionParameter(
              type: 'Object'.nullableTypeString,
              name: field,
              defaultValue: '_defaultValue',
            ),
        ],
        // Always call the generated factory so extra user-factory-only params
        // (e.g. construction flags) are not required.
        returnValue:
            '''${generatedClassNames.generatedFormBodyClassName}(${copyWithFields.join()})''',
        isOverride: true,
      )
      ..writeClassDeclarationEnd();
  }

  /// copyWith accepts FormField instances for custom wrappers and raw values
  /// for inferred wrappers.
  String _copyWithParameterType(FormBodyFieldMetadata field) {
    if (field.isCustomWrapper) {
      return field.formClassName;
    }
    return field.rawValueType.potentiallyNullableDisplayString;
  }

  String _copyWithArgument(FormBodyFieldMetadata field) {
    final name = field.fieldName;
    if (field.isCustomWrapper) {
      return '''
$name: $name == _defaultValue ? _instance._$name : $name as ${field.formClassName},''';
    }

    final rawType = field.rawValueType.potentiallyNullableDisplayString;
    return '''
$name: $name == _defaultValue ? _instance._${_getRawValue(field)} : $name as $rawType,''';
  }
}
