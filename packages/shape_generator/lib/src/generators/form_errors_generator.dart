import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/generators/generators.dart';
import 'package:shape_generator/src/models/models.dart';

/// {@template form_errors_generator}
/// The code generator for form error classes.
/// {@endtemplate}
class FormErrorsGenerator extends SourceGenerator {
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
  String generate() {
    writeComment(
      'Form Errors "${generatedClassNames.generatedFormErrorsClassName}"',
    );

    writeImmutableAnnotation();
    writeClassDeclarationStart(
      documentation: 'The form errors for the form body '
          '"${generatedClassNames.formBodyClassName}".',
      name: generatedClassNames.generatedFormErrorsClassName,
      extendedClass:
          'FormErrors<${generatedClassNames.generatedFormBodyClassName}>',
      mixins: ['EquatableMixin'],
    );

    writeClassConstructor(
      documentation: 'The form errors for the form body '
          '"${generatedClassNames.formBodyClassName}".',
      className: generatedClassNames.generatedFormErrorsClassName,
      constructorName: '',
      parameters: [
        for (final field in fields)
          FunctionParameter(
            // Doesn't show up in a constructor.
            type: field.errorType.nonNullableDisplayString.nullableTypeString,
            name: field.fieldIdentifier.name,
          ),
      ],
      useConstConstructor: true,
      useNamedParameters: true,
    );

    for (final field in fields) {
      writeClassField(
        documentation: 'The error for the ${field.fieldIdentifier.name} field.',
        type: field.errorType.nonNullableDisplayString.nullableTypeString,
        name: field.fieldIdentifier.name,
        isFinal: true,
      );
    }

    final mergeWhereEmptyWithFields = [
      for (final field in fields)
        '''${field.fieldIdentifier.name}: ${field.fieldIdentifier.name} ?? other.${field.fieldIdentifier.name},'''
    ];
    writeSingleReturnFunction(
      documentation: '''
Merges this ${generatedClassNames.generatedFormErrorsClassName} with the [other] by replacing
any empty fields in this instance with the corresponding field in [other].
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
    );

    writeClassGetter(
      documentation: '''
Copies this ${generatedClassNames.generatedFormErrorsClassName} and replaces the provided fields.''',
      type: generatedClassNames.generatedErrorsCopyWithClassName,
      name: 'copyWith',
      value:
          '${generatedClassNames.generatedErrorsCopyWithImplClassName}(this)',
    );

    writeClassGetter(
      type: 'List<${'Object'.nullableTypeString}>',
      name: 'errors',
      value: '[${fields.map((f) => '${f.fieldIdentifier.name},').join()}]',
      isOverride: true,
    );

    writeClassGetter(
      type: 'List<${'Object'.nullableTypeString}>',
      name: 'props',
      value: 'errors',
      isOverride: true,
    );

    writeClassGetter(
      type: 'bool',
      name: 'stringify',
      value: 'true',
      isOverride: true,
    );

    writeClassDeclarationEnd();

    writeComment(
      '''Copy With Interface "${generatedClassNames.generatedErrorsCopyWithClassName}"''',
    );

    writeClassDeclarationStart(
      name: generatedClassNames.generatedErrorsCopyWithClassName,
      isAbstract: true,
    );

    writeBodylessFunction(
      returnType: generatedClassNames.generatedFormErrorsClassName,
      functionName: 'call',
      parameters: [
        for (final field in fields)
          FunctionParameter(
            type: field
                .errorType.potentiallyNullableDisplayString.nullableTypeString,
            name: field.fieldIdentifier.name,
            isRequired: false,
          ),
      ],
    );

    writeClassDeclarationEnd();

    writeComment(
      '''Copy With Implementation "${generatedClassNames.generatedErrorsCopyWithImplClassName}"''',
    );

    writeClassDeclarationStart(
      name: generatedClassNames.generatedErrorsCopyWithImplClassName,
      implementedInterfaces: [
        generatedClassNames.generatedErrorsCopyWithClassName
      ],
    );

    writeClassConstructor(
      className: generatedClassNames.generatedErrorsCopyWithImplClassName,
      parameters: [
        FunctionParameter(
          type: generatedClassNames.generatedFormErrorsClassName,
          name: '_instance',
        ),
      ],
    );

    writeClassField(
      type: generatedClassNames.generatedFormErrorsClassName,
      name: '_instance',
    );

    writeStaticConstClassField(
      name: '_defaultValue',
      value: 'Object()',
    );

    final copyWithFields = [
      for (final field in fields)
        // ignore: no_adjacent_strings_in_list
        '${field.fieldIdentifier.name}: '
            '${field.fieldIdentifier.name} == _defaultValue '
            '? _instance.${field.fieldIdentifier.name} '
            ': ${field.fieldIdentifier.name} as ${field.errorType.potentiallyNullableDisplayString.nullableTypeString},',
    ];
    writeSingleReturnFunction(
      returnType: generatedClassNames.generatedFormErrorsClassName,
      functionName: 'call',
      parameters: [
        for (final field in fields)
          FunctionParameter(
            type: 'Object'.nullableTypeString,
            name: field.fieldIdentifier.name,
            defaultValue: '_defaultValue',
          ),
      ],
      returnValue:
          '${generatedClassNames.generatedFormErrorsClassName}(${copyWithFields.join()})',
      isOverride: true,
    );

    writeClassDeclarationEnd();

    return generateSource();
  }
}
