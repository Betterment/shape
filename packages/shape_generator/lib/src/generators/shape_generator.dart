import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:shape/shape.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/generators/generators.dart';
import 'package:shape_generator/src/models/models.dart';
import 'package:source_gen/source_gen.dart';

/// The [Generator] for Shape.
class ShapeGenerator extends GeneratorForAnnotation<GenerateFormBody> {
  static const _fieldRequiredChecker = TypeChecker.typeNamed(
    FieldRequired,
    inPackage: 'shape',
  );

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final annotationInstance = _getAnnotationFromReader(annotation);

    await _validateClassDeclaration(element, buildStep);
    await _validateConstructors(element, buildStep);

    final classMetadata = ClientClassMetadata.fromElement(element);
    final formBodyFields = await _getFormBodyFieldMetadata(element, buildStep);
    final generatedClassNames = GeneratedClassNames(
      formBodyClassName: classMetadata.name,
    );

    final buffer = SourceBuffer();

    try {
      FormBodyGenerator(
        enclosingClassMetadata: classMetadata,
        generatedClassNames: generatedClassNames,
        fields: formBodyFields,
      ).write(buffer);

      FormFieldsMixinGenerator(
        enclosingClassMetadata: classMetadata,
        generatedClassNames: generatedClassNames,
        fields: formBodyFields,
      ).write(buffer);

      if (annotationInstance.generateFormErrors) {
        FormErrorsGenerator(
          enclosingClassMetadata: classMetadata,
          generatedClassNames: generatedClassNames,
          fields: formBodyFields,
        ).write(buffer);
      }

      return buffer.dump();
    } catch (e) {
      throw Exception('''
An unknown error occurred while generating the form body for "${element.name ?? '<unnamed>'}".
Please make sure your class is valid and try again.

If this issue keeps occurring please report an issue at
  https://github.com/Betterment/shape/issues/new

-----------------------------------------------
               Error Details
-----------------------------------------------

$e

-----------------------------------------------
''');
    }
  }

  GenerateFormBody _getAnnotationFromReader(ConstantReader annotation) {
    T? getValue<T>(String field, T? Function(ConstantReader) predicate) {
      return predicate(annotation.read(field));
    }

    bool? getBool(String field, {bool? orElse}) {
      return getValue<bool>(field, (f) => !f.isBool ? orElse : f.boolValue);
    }

    return GenerateFormBody(generateFormErrors: getBool('generateFormErrors'));
  }

  Future<void> _validateClassDeclaration(
    Element element,
    BuildStep buildStep,
  ) async {
    final classMetadata = ClientClassMetadata.fromElement(element);
    final generatedClassNames = GeneratedClassNames(
      formBodyClassName: classMetadata.name,
    );

    final isAbstract = classMetadata.isAbstract;
    final extendsFormBody =
        classMetadata.supertype != null &&
        classMetadata.supertype!.nonNullableDisplayString ==
            kFormBodyBaseClassName;
    final hasGenerativeConstructor = classMetadata.constructors.any(
      (constructor) =>
          !constructor.isFactory &&
          constructor.name == '_' &&
          constructor.formalParameters.isEmpty,
    );
    final hasNamelessFactoryConstructor = classMetadata.constructors.any(
      (c) => (c.name == null || c.name == '' || c.name == 'new') && c.isFactory,
    );

    final validateMethodOverrides = classMetadata.methods.where(
      (method) => method.name == kValidateMethodName && !method.isAbstract,
    );
    final hasValidValidateMethod =
        validateMethodOverrides.isEmpty || validateMethodOverrides.length == 1;

    final isValid =
        isAbstract &&
        extendsFormBody &&
        hasGenerativeConstructor &&
        hasNamelessFactoryConstructor &&
        hasValidValidateMethod;

    if (!isValid) {
      throw Exception('''
The class "${classMetadata.name}" is not a valid form body.

Please make sure your form body class:
${isAbstract ? '✅' : '❌'} is abstract.
${extendsFormBody ? '✅' : '❌'} extends ${generatedClassNames.extendingFormBodyClassName}.
${hasGenerativeConstructor ? '✅' : '❌'} has a private parameterless generative constructor ("const ${classMetadata.name}._();").
${hasNamelessFactoryConstructor ? '✅' : '❌'} has a nameless factory constructor that returns a "${generatedClassNames.generatedFormBodyClassName}".
${hasValidValidateMethod ? '✅' : '❌'} has no validate method OR a single validate method that returns a "${generatedClassNames.generatedFormErrorsClassName}".
''');
    }
  }

  Future<ClientConstructorMetadata> _validateConstructors(
    Element element,
    BuildStep buildStep,
  ) async {
    final classMetadata = ClientClassMetadata.fromElement(element);
    final generatedClassNames = GeneratedClassNames(
      formBodyClassName: classMetadata.name,
    );

    final constructors = await _getClientConstructorData(element, buildStep);

    if (constructors.isEmpty) {
      throw Exception(
        '''
No constructors found in class "${generatedClassNames.formBodyClassName}".
There must be exactly one factory constructor
that returns an instance of "${generatedClassNames.generatedFormBodyClassName}".''',
      );
    }

    final validConstructors = constructors.where(
      (constructor) => constructor.isValid,
    );

    if (validConstructors.isEmpty) {
      throw Exception(
        '''
No valid constructors found in class "${generatedClassNames.formBodyClassName}".
There must be exactly one factory constructor
that returns an instance of "${generatedClassNames.generatedFormBodyClassName}".''',
      );
    } else if (validConstructors.length > 1) {
      throw Exception(
        '''
Multiple valid constructors found in class "${generatedClassNames.formBodyClassName}".
There must be exactly one factory constructor
that returns an instance of "${generatedClassNames.generatedFormBodyClassName}".''',
      );
    }

    return validConstructors.first;
  }

  Future<List<ClientConstructorMetadata>> _getClientConstructorData(
    Element element,
    BuildStep buildStep,
  ) async {
    final classMetadata = ClientClassMetadata.fromElement(element);
    final constructorDeclarationNodes = await _getConstructorDeclarationNodes(
      classMetadata.constructors,
      buildStep,
    );

    final constructorReturnExpressions = [
      for (final constructorDeclaration in constructorDeclarationNodes)
        _getReturnExpression(constructorDeclaration),
    ];
    final constructorRedirectTargetNames = [
      for (final constructorDeclaration in constructorDeclarationNodes)
        _getRedirectTargetName(constructorDeclaration),
    ];
    final result = [
      for (var i = 0; i < classMetadata.constructors.length; i++)
        ClientConstructorMetadata(
          name: classMetadata.constructors[i].name ?? 'new',
          enclosingClass: classMetadata.constructors[i].returnType,
          isFactory: classMetadata.constructors[i].isFactory,
          returnExpression: constructorReturnExpressions[i],
          redirectTarget: classMetadata.constructors[i].redirectedConstructor,
          redirectTargetName: constructorRedirectTargetNames[i],
        ),
    ];

    return result;
  }

  Future<List<ConstructorDeclaration>> _getConstructorDeclarationNodes(
    List<ConstructorElement> constructors,
    BuildStep buildStep,
  ) async {
    final result = <ConstructorDeclaration>[];
    for (final constructor in constructors) {
      final astNode = await buildStep.resolver.astNodeFor(
        constructor.firstFragment,
        resolve: true,
      );
      final visitor = _ConstructorAstVisitor();
      astNode?.accept<dynamic>(visitor);
      if (visitor.node != null) {
        result.add(visitor.node!);
      }
    }

    return result;
  }

  String? _getRedirectTargetName(ConstructorDeclaration declaration) {
    final redirect = declaration.redirectedConstructor;
    if (redirect == null) {
      return null;
    }

    return redirect.type.name.lexeme;
  }

  Expression? _getReturnExpression(ConstructorDeclaration declaration) {
    if (declaration.redirectedConstructor != null) {
      return null;
    }

    for (final childEntity in declaration.childEntities) {
      if (childEntity is BlockFunctionBody) {
        for (final statement in childEntity.block.statements) {
          if (statement is ReturnStatement) {
            return statement.expression;
          }
        }
      }
      if (childEntity is ExpressionFunctionBody) {
        return childEntity.expression;
      }
    }

    return null;
  }

  Future<List<FormBodyFieldMetadata>> _getFormBodyFieldMetadata(
    Element element,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw Exception('Expected a ClassElement.');
    }

    final classMetadata = ClientClassMetadata.fromElement(element);
    final generatedClassNames = GeneratedClassNames(
      formBodyClassName: classMetadata.name,
    );

    final constructorMetadata = await _getClientConstructorData(
      element,
      buildStep,
    ).then((results) => results.firstWhere((c) => c.isValid));

    final returnExpression = constructorMetadata.returnExpression;
    if (constructorMetadata.redirectTarget != null ||
        constructorMetadata.redirectTargetName != null) {
      return _buildFieldsFromFactoryParameters(
        element: element,
        buildStep: buildStep,
        classMetadata: classMetadata,
        generatedClassNames: generatedClassNames,
      );
    }

    final expression = returnExpression;
    if (expression is! MethodInvocation &&
        expression is! InstanceCreationExpression) {
      throw Exception('''
No method invocation found in return statement.

-----------------------------------------------

shape_generator only supports return statements that are immediately followed
by a constructor invocation of the form body class.

Please make sure your return statement looks like the following:

  return ${generatedClassNames.generatedFormBodyClassName}(
    foo: foo,
    bar: bar,
  );

For custom form fields, pass a form field constructor invocation:

  return ${generatedClassNames.generatedFormBodyClassName}(
    foo: FooFormField(rawValue: foo),
  );

-----------------------------------------------

Expression found was: "$expression".''');
    }

    final generatedFormBodyClassName = expression is MethodInvocation
        ? expression.methodName
        : (expression as InstanceCreationExpression).constructorName.name!;
    assert(
      generatedFormBodyClassName.name ==
          constructorMetadata.returnExpressionTypeName,
    );
    assert(
      generatedFormBodyClassName.name ==
          generatedClassNames.generatedFormBodyClassName,
    );

    final factoryConstructor = classMetadata.constructors.firstWhere(
      (constructor) =>
          (constructor.name == null ||
              constructor.name == '' ||
              constructor.name == 'new') &&
          constructor.isFactory,
    );
    final factoryParameters = {
      for (final parameter in factoryConstructor.formalParameters)
        if (parameter.name != null) parameter.name!: parameter,
    };

    final result = <FormBodyFieldMetadata>[];
    final formBodyArguments = expression is MethodInvocation
        ? expression.argumentList.arguments
        : (expression as InstanceCreationExpression).argumentList.arguments;

    for (var i = 0; i < formBodyArguments.length; i++) {
      final formBodyArgument = formBodyArguments[i];
      if (formBodyArgument is! NamedArgument) {
        throw Exception(
          '''
The argument at index $i in the "$generatedFormBodyClassName" construction
is not a named argument.

-----------------------------------------------

Please make sure that all arguments are named parameters.

-----------------------------------------------

Argument found: "$formBodyArgument" (of type ${formBodyArgument.runtimeType})''',
        );
      }

      final formFieldName = formBodyArgument.name.lexeme;
      if (formFieldName.startsWith('_')) {
        throw Exception('''
The form field with name "$formFieldName" is not a valid identifier.

-----------------------------------------------

Form field names cannot be provided as a private parameter and can therefor
not start with an underscore.

-----------------------------------------------

Form field name found: "$formFieldName"''');
      }

      final argumentExpression = formBodyArgument.argumentExpression;
      final factoryParameter = factoryParameters[formFieldName];
      if (factoryParameter == null) {
        throw Exception(
          'Factory parameter "$formFieldName" was not found on '
          '"${classMetadata.name}".',
        );
      }

      if (argumentExpression is SimpleIdentifier) {
        result.add(
          await _buildInferredFormBodyFieldMetadata(
            element: element,
            buildStep: buildStep,
            fieldName: formFieldName,
            factoryParameter: factoryParameter,
          ),
        );
        continue;
      }

      if (argumentExpression is MethodInvocation ||
          argumentExpression is InstanceCreationExpression) {
        result.add(
          _buildCustomFormBodyFieldMetadata(
            fieldName: formFieldName,
            argumentExpression: argumentExpression,
            factoryParameter: factoryParameter,
          ),
        );
        continue;
      }

      throw Exception('''
Could not determine how to wrap the form field with name "$formFieldName".

Pass either the factory parameter directly for automatic GenericFormField
wrapping, or a form field constructor invocation for custom validation.

Expression found: "$argumentExpression".''');
    }

    return result;
  }

  Future<List<FormBodyFieldMetadata>> _buildFieldsFromFactoryParameters({
    required ClassElement element,
    required BuildStep buildStep,
    required ClientClassMetadata classMetadata,
    required GeneratedClassNames generatedClassNames,
  }) async {
    final factoryConstructor = classMetadata.constructors.firstWhere(
      (constructor) =>
          (constructor.name == null ||
              constructor.name == '' ||
              constructor.name == 'new') &&
          constructor.isFactory,
    );

    final result = <FormBodyFieldMetadata>[];
    for (final parameter in factoryConstructor.formalParameters) {
      if (parameter.name == null) {
        continue;
      }

      result.add(
        await _buildInferredFormBodyFieldMetadata(
          element: element,
          buildStep: buildStep,
          fieldName: parameter.name!,
          factoryParameter: parameter,
        ),
      );
    }

    return result;
  }

  Future<FormBodyFieldMetadata> _buildInferredFormBodyFieldMetadata({
    required ClassElement element,
    required BuildStep buildStep,
    required String fieldName,
    required FormalParameterElement factoryParameter,
  }) async {
    final genericFormFieldClass = await _findGenericFormFieldClass(
      element,
      buildStep,
    );
    if (genericFormFieldClass == null) {
      throw Exception('''
Could not infer a form field wrapper for "$fieldName".

Import `package:shape_starter_kit/shape_starter_kit.dart` to use automatic
GenericFormField wrapping, or pass an explicit form field constructor.
''');
    }

    final parameterType = factoryParameter.type;
    final isRequired =
        factoryParameter.isRequired ||
        _hasFieldRequiredAnnotation(factoryParameter);

    final wrapperExpression =
        'GenericFormField<${parameterType.getDisplayString()}>'
        '($fieldName${isRequired ? ', isRequired: true' : ''})';

    return FormBodyFieldMetadata(
      fieldName: fieldName,
      formClassMetadata: ClientClassMetadata.fromElement(genericFormFieldClass),
      wrapperExpression: wrapperExpression,
      isFactoryParameterRequired: factoryParameter.isRequired,
      genericTypeArguments: {
        if (genericFormFieldClass.typeParameters.isNotEmpty)
          genericFormFieldClass.typeParameters.first: parameterType,
      },
    );
  }

  FormBodyFieldMetadata _buildCustomFormBodyFieldMetadata({
    required String fieldName,
    required Expression argumentExpression,
    required FormalParameterElement factoryParameter,
  }) {
    final formFieldExpressionType = argumentExpression.staticType;
    ClassElement? formFieldClassElement;

    final expressionElement = formFieldExpressionType?.element;
    if (expressionElement is ClassElement) {
      formFieldClassElement = expressionElement;
    }

    if (formFieldClassElement == null) {
      throw Exception('''
Could not determine the type of the form field with name "$fieldName".
The form field is not a class or a simple identifier.

-----------------------------------------------

Make sure that you have imported all necessary libraries and that the referenced
form field exists.

Expression found: $argumentExpression''');
    }

    final formFieldClassMetadata = ClientClassMetadata.fromElement(
      formFieldClassElement,
      withInstanceType: formFieldExpressionType,
    );

    final instanceTypeArguments = <DartType>[];

    if (formFieldClassMetadata.instanceType != null &&
        formFieldClassMetadata.instanceType is ParameterizedType) {
      final instanceType =
          formFieldClassMetadata.instanceType! as ParameterizedType;
      instanceTypeArguments.addAll(instanceType.typeArguments);
    }

    if (formFieldClassMetadata.typeParameters.length !=
        instanceTypeArguments.length) {
      throw Exception(
        '''
The number of type parameters of the form field class "${formFieldClassMetadata.name}"
does not match the number of type arguments of the instance of the form field.

Type parameters found: "${formFieldClassMetadata.typeParameters}" (length ${formFieldClassMetadata.typeParameters.length})
Instance type arguments found: "$instanceTypeArguments" (length ${instanceTypeArguments.length})''',
      );
    }

    return FormBodyFieldMetadata(
      fieldName: fieldName,
      formClassMetadata: formFieldClassMetadata,
      wrapperExpression: argumentExpression.toSource(),
      isCustomWrapper: true,
      isFactoryParameterRequired: factoryParameter.isRequired,
      genericTypeArguments: {
        for (var i = 0; i < formFieldClassMetadata.typeParameters.length; i++)
          formFieldClassMetadata.typeParameters[i]: instanceTypeArguments[i],
      },
    );
  }

  Future<ClassElement?> _findGenericFormFieldClass(
    ClassElement element,
    BuildStep buildStep,
  ) async {
    final local = element.library.getClass('GenericFormField');
    if (local != null) {
      return local;
    }

    for (final imported in element.library.firstFragment.importedLibraries) {
      final genericFormField = imported.getClass('GenericFormField');
      if (genericFormField != null) {
        return genericFormField;
      }
    }

    for (final uri in const [
      'package:shape_starter_kit/shape_starter_kit.dart',
      'package:shape_starter_kit/src/form_fields/generic_form_field.dart',
    ]) {
      try {
        final library = await buildStep.resolver.libraryFor(
          AssetId.resolve(Uri.parse(uri), from: buildStep.inputId),
        );
        final genericFormField = library.getClass('GenericFormField');
        if (genericFormField != null) {
          return genericFormField;
        }
      } on Object {
        continue;
      }
    }

    return null;
  }

  bool _hasFieldRequiredAnnotation(FormalParameterElement parameter) {
    return _fieldRequiredChecker.hasAnnotationOfExact(parameter);
  }
}

class _ConstructorAstVisitor extends SimpleAstVisitor<dynamic> {
  ConstructorDeclaration? node;
  SimpleIdentifier? identifier;

  @override
  dynamic visitConstructorDeclaration(ConstructorDeclaration node) {
    this.node = node;
  }

  @override
  dynamic visitConstructorName(ConstructorName node) {
    node.visitChildren(this);
  }

  @override
  dynamic visitSimpleIdentifier(SimpleIdentifier node) {
    identifier = node;
    node.visitChildren(this);
  }
}
