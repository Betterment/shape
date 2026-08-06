import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/generators/generators.dart';
import 'package:shape_generator/src/models/models.dart';

/// {@template form_errors_generator}
/// The code generator for form error classes.
/// {@endtemplate}
class FormErrorsGenerator with SourceGenerator {
  /// {@macro form_errors_generator}
  FormErrorsGenerator({
    required this.enclosingClassMetadata,
    required this.generatedClassNames,
    required this.fields,
  });

  /// The metadata for the class that is being generated.
  final ClientClassMetadata enclosingClassMetadata;

  /// The generated class names for the class that is being generated.
  final GeneratedClassNames generatedClassNames;

  /// The fields that the form body contains.
  final List<FormBodyFieldMetadata> fields;

  @override
  void write(SourceBuffer buffer) {
    buffer
      ..writeComment(
        'Form Errors "${generatedClassNames.generatedFormErrorsClassName}"',
      )
      ..writeImmutableAnnotation()
      ..writeClassDeclarationStart(
        documentation:
            'The form errors for the form body '
            '"${generatedClassNames.formBodyClassName}".',
        name: generatedClassNames.generatedFormErrorsClassName,
        extendedClass: 'FormErrors',
        mixins: [],
      )
      ..writeClassConstructor(
        documentation:
            'The form errors for the form body '
            '"${generatedClassNames.formBodyClassName}".',
        className: generatedClassNames.generatedFormErrorsClassName,
        constructorName: '',
        parameters: [
          for (final field in fields)
            FunctionParameter(
              // Doesn't show up in a constructor.
              type: field.errorType.nonNullableDisplayString.nullableTypeString,
              name: field.fieldName,
            ),
        ],
        useConstConstructor: true,
        useNamedParameters: true,
      );

    for (final field in fields) {
      buffer.writeClassField(
        documentation: 'The error for the ${field.fieldName} field.',
        type: field.errorType.nonNullableDisplayString.nullableTypeString,
        name: field.fieldName,
        isFinal: true,
      );
    }

    final mergeWhereEmptyWithFields = [
      for (final field in fields)
        '''${field.fieldName}: ${field.fieldName} ?? other.${field.fieldName},''',
    ];
    buffer
      ..writeSingleReturnFunction(
        documentation:
            '''
Merges this ${generatedClassNames.generatedFormErrorsClassName} with the [other]
by replacing any empty fields in this instance with the corresponding field in
[other] while preserving the non-empty fields in this instance.
''',
        returnType: generatedClassNames.generatedFormErrorsClassName,
        functionName: 'mergeWhereEmptyWith',
        parameters: [
          FunctionParameter(
            type: generatedClassNames.generatedFormErrorsClassName,
            name: 'other',
            isRequired: true,
          ),
        ],
        returnValue:
            '''${generatedClassNames.generatedFormErrorsClassName}(${mergeWhereEmptyWithFields.join()})''',
      )
      ..writeClassGetter(
        documentation: '''
Copies this ${generatedClassNames.generatedFormErrorsClassName} and replaces the provided fields.''',
        type: generatedClassNames.generatedErrorsCopyWithClassName,
        name: 'copyWith',
        value:
            '${generatedClassNames.generatedErrorsCopyWithImplClassName}(this)',
      )
      ..writeClassGetter(
        type: 'List<${'Object'.nullableTypeString}>',
        name: 'errors',
        value: '[${fields.map((f) => '${f.fieldName},').join()}]',
        isOverride: true,
      )
      ..writeEqualityOperators(
        className: generatedClassNames.generatedFormErrorsClassName,
        equalityFields: fields.map((field) => field.fieldName).toList(),
      )
      ..writeClassDeclarationEnd()
      ..writeComment(
        '''Copy With Interface "${generatedClassNames.generatedErrorsCopyWithClassName}"''',
      )
      ..writeClassDeclarationStart(
        name: generatedClassNames.generatedErrorsCopyWithClassName,
        isAbstract: true,
      )
      ..writeBodylessFunction(
        returnType: generatedClassNames.generatedFormErrorsClassName,
        functionName: 'call',
        parameters: [
          for (final field in fields)
            FunctionParameter(
              type: field
                  .errorType
                  .potentiallyNullableDisplayString
                  .nullableTypeString,
              name: field.fieldName,
              isRequired: false,
            ),
        ],
      )
      ..writeClassDeclarationEnd()
      ..writeComment(
        '''Copy With Implementation "${generatedClassNames.generatedErrorsCopyWithImplClassName}"''',
      )
      ..writeClassDeclarationStart(
        name: generatedClassNames.generatedErrorsCopyWithImplClassName,
        implementedInterfaces: [
          generatedClassNames.generatedErrorsCopyWithClassName,
        ],
      )
      ..writeClassConstructor(
        className: generatedClassNames.generatedErrorsCopyWithImplClassName,
        parameters: [
          FunctionParameter(
            type: generatedClassNames.generatedFormErrorsClassName,
            name: '_instance',
          ),
        ],
      )
      ..writeClassField(
        type: generatedClassNames.generatedFormErrorsClassName,
        name: '_instance',
      )
      ..writeStaticConstClassField(name: '_defaultValue', value: 'Object()');

    final copyWithFields = [
      for (final field in fields)
        '''${field.fieldName}: ${field.fieldName} == _defaultValue ? _instance.${field.fieldName} : ${field.fieldName} as ${field.errorType.potentiallyNullableDisplayString.nullableTypeString},''',
    ];
    buffer
      ..writeSingleReturnFunction(
        returnType: generatedClassNames.generatedFormErrorsClassName,
        functionName: 'call',
        parameters: [
          for (final field in fields)
            FunctionParameter(
              type: 'Object'.nullableTypeString,
              name: field.fieldName,
              defaultValue: '_defaultValue',
            ),
        ],
        returnValue:
            '''${generatedClassNames.generatedFormErrorsClassName}(${copyWithFields.join()})''',
        isOverride: true,
      )
      ..writeClassDeclarationEnd();
  }
}
