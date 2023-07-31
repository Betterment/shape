import 'package:forms_generator/src/extensions/extensions.dart';
import 'package:forms_generator/src/generators/generators.dart';
import 'package:forms_generator/src/models/models.dart';

class FormBodyGenerator extends SourceGenerator {
  FormBodyGenerator({
    required this.enclosingClassMetadata,
    required this.generatedClassNames,
    required this.fields,
  });

  final ClientClassMetadata enclosingClassMetadata;
  final GeneratedClassNames generatedClassNames;
  final List<FormBodyFieldMetadata> fields;

  String _getValue(FormBodyFieldMetadata field) {
    final name = field.fieldIdentifier.name;
    if (!field.extendsFormField) {
      return name;
    } else {
      return '$name.value';
    }
  }

  String _getRawValue(FormBodyFieldMetadata field) {
    final name = field.fieldIdentifier.name;
    if (!field.extendsFormField) {
      return name;
    } else {
      return '$name.rawValue';
    }
  }

  @override
  String generate() {
    writeComment(
      'Form Body "${generatedClassNames.generatedFormBodyClassName}"',
    );

    writeImmutableAnnotation();
    writeClassDeclarationStart(
      name: generatedClassNames.generatedFormBodyClassName,
      extendedClass: generatedClassNames.formBodyClassName,
      mixins: [
        generatedClassNames.generatedFormBodyFieldsMixinName,
        'EquatableMixin'
      ],
    );

    writeClassFactoryConstructor(
      className: generatedClassNames.generatedFormBodyClassName,
      factoryName: '',
      constructorName: '_',
      parameters: [
        for (final field in fields)
          FunctionParameter(
            type: field.formClassName,
            name: field.fieldIdentifier.name,
            isRequired: true,
          ),
      ],
    );

    writeClassConstructor(
      className: generatedClassNames.generatedFormBodyClassName,
      constructorName: '_',
      parameters: [
        for (final field in fields)
          FunctionParameter(
            type: field.formClassName,
            name: '_${field.fieldIdentifier.name}',
          ),
      ],
      useConstConstructor: true,
      useNamedParameters: false,
      supertypeConstructorName: '_',
      passParametersToSuper: false,
    );

    for (final field in fields) {
      writeClassField(
        type: field.formClassName,
        name: '_${field.fieldIdentifier.name}',
        isFinal: true,
        isOverride: true,
      );
      writeClassGetter(
        type: field.valueType.potentiallyNullableDisplayString,
        name: field.fieldIdentifier.name,
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
          .map((f) => f.fieldIdentifier.name);
      writeSingleReturnFunction(
        returnType: generatedClassNames.generatedFormErrorsClassName,
        functionName: kValidateMethodName,
        returnValue: '${generatedClassNames.generatedFormErrorsClassName}'
            '(${validationFields.map((f) => '$f: _$f.validate(),').join()})',
        isOverride: true,
      );
    }

    writeClassGetter(
      type: generatedClassNames.generatedCopyWithClassName,
      name: 'copyWith',
      value: '${generatedClassNames.generatedCopyWithImplClassName}(this)',
      isOverride: true,
    );

    writeClassGetter(
      type: 'List<${'Object'.nullableTypeString}>',
      name: 'props',
      value: '[${fields.map((f) => '_${_getRawValue(f)},').join()}]',
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
      'Copy With Interface "${generatedClassNames.generatedCopyWithClassName}"',
    );

    writeClassDeclarationStart(
      name: generatedClassNames.generatedCopyWithClassName,
      isAbstract: true,
    );

    writeBodylessFunction(
      returnType: generatedClassNames.formBodyClassName,
      functionName: 'call',
      parameters: [
        for (final field in fields)
          FunctionParameter(
            type: field.rawValueType.potentiallyNullableDisplayString,
            name: field.fieldIdentifier.name,
            isRequired: false,
          ),
      ],
    );

    writeClassDeclarationEnd();

    writeComment(
      'Copy With Implementation "${generatedClassNames.generatedCopyWithImplClassName}"',
    );

    writeClassDeclarationStart(
      name: generatedClassNames.generatedCopyWithImplClassName,
      implementedInterfaces: [generatedClassNames.generatedCopyWithClassName],
    );

    writeClassConstructor(
      className: generatedClassNames.generatedCopyWithImplClassName,
      parameters: [
        FunctionParameter(
          type: generatedClassNames.generatedFormBodyClassName,
          name: '_instance',
        ),
      ],
    );

    writeClassField(
      type: generatedClassNames.generatedFormBodyClassName,
      name: '_instance',
    );

    writeStaticConstClassField(
      name: '_defaultValue',
      value: 'Object()',
    );

    final fieldNames = fields.map((f) => f.fieldIdentifier.name);
    final copyWithFields = [
      for (final field in fields)
        // ignore: no_adjacent_strings_in_list
        '${field.fieldIdentifier.name}: '
            '${field.fieldIdentifier.name} == _defaultValue '
            '? _instance._${_getRawValue(field)} '
            ': ${field.fieldIdentifier.name} as ${field.rawValueType.potentiallyNullableDisplayString},',
    ];

    writeSingleReturnFunction(
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
      returnValue:
          '${generatedClassNames.formBodyClassName}(${copyWithFields.join()})',
      isOverride: true,
    );

    writeClassDeclarationEnd();

    return generateSource();
  }
}
