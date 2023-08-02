import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/generators/generators.dart';
import 'package:shape_generator/src/models/models.dart';

class FormFieldsMixinGenerator extends SourceGenerator {
  FormFieldsMixinGenerator({
    required this.enclosingClassMetadata,
    required this.generatedClassNames,
    required this.fields,
  });

  final ClientClassMetadata enclosingClassMetadata;
  final GeneratedClassNames generatedClassNames;
  final List<FormBodyFieldMetadata> fields;

  @override
  String generate() {
    writeComment(
      'Form Fields Mixin "${generatedClassNames.generatedFormBodyFieldsMixinName}"',
    );

    writeMixinDeclarationStart(
      name: generatedClassNames.generatedFormBodyFieldsMixinName,
    );

    for (final field in fields) {
      writeBodylessClassGetter(
        documentation: '''
The internal ${field.fieldIdentifier.name} field form field.

This property should not be exposed and is only to be used when implementing a
custom `validate` method.
''',
        type: field.formClassName,
        name: '_${field.fieldIdentifier.name}',
      );
      writeBodylessClassGetter(
        documentation:
            'The parsed value of the ${field.fieldIdentifier.name} field.',
        type: field.valueType.potentiallyNullableDisplayString,
        name: field.fieldIdentifier.name,
      );
    }

    writeBodylessFunction(
      returnType: generatedClassNames.generatedFormErrorsClassName,
      functionName: kValidateMethodName,
    );

    writeBodylessClassGetter(
      documentation:
          'Copies this ${generatedClassNames.formBodyClassName} and replaces the provided fields.',
      type: generatedClassNames.generatedCopyWithClassName,
      name: 'copyWith',
    );

    writeMixinDeclarationEnd();

    return generateSource();
  }
}
