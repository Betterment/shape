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
    final generatedClassNames =
        GeneratedClassNames(formBodyClassName: classMetadata.name);

    try {
      final formBodySource = FormBodyGenerator(
        enclosingClassMetadata: classMetadata,
        generatedClassNames: generatedClassNames,
        fields: formBodyFields,
      ).generate();

      final formFieldsMixinSource = FormFieldsMixinGenerator(
        enclosingClassMetadata: classMetadata,
        generatedClassNames: generatedClassNames,
        fields: formBodyFields,
      ).generate();

      final formErrorsSource = !annotationInstance.generateFormErrors
          ? ''
          : FormErrorsGenerator(
              enclosingClassMetadata: classMetadata,
              generatedClassNames: generatedClassNames,
              fields: formBodyFields,
            ).generate();

      final source = '''
$formBodySource

$formFieldsMixinSource

$formErrorsSource''';

      return source;
    } catch (e) {
      throw Exception(
        '''
An unknown error occurred while generating the form body for "${element.name}".
Please report this error to the Flutter engineering team.

-----------------------------------------------
               Error Details
-----------------------------------------------

$e

-----------------------------------------------
''',
      );
    }
  }

  GenerateFormBody _getAnnotationFromReader(ConstantReader annotation) {
    T? getValue<T>(String field, T? Function(ConstantReader) predicate) {
      return predicate(annotation.read(field));
    }

    bool? getBool(
      String field, {
      bool? orElse,
    }) {
      return getValue<bool>(field, (f) => !f.isBool ? orElse : f.boolValue);
    }

    return GenerateFormBody(
      generateFormErrors: getBool('generateFormErrors'),
    );
  }

  Future<void> _validateClassDeclaration(
    Element element,
    BuildStep buildStep,
  ) async {
    final classMetadata = ClientClassMetadata.fromElement(element);
    final generatedClassNames =
        GeneratedClassNames(formBodyClassName: classMetadata.name);

    final isAbstract = classMetadata.isAbstract;
    final extendsFormBody = classMetadata.supertype != null &&
        classMetadata.supertype!.nonNullableDisplayString
            .startsWith(kFormBodyBaseClassName);
    final hasNamelessFactoryConstructor =
        classMetadata.constructors.any((c) => c.name == '' && c.isFactory);
    final hasPrivateConstructor = classMetadata.constructors.any(
      (c) => c.isPrivate && c.name == '_' && c.isConst && c.parameters.isEmpty,
    );

    final validateMethodOverrides = classMetadata.methods.where(
      (method) => method.name == kValidateMethodName && !method.isAbstract,
    );
    final hasValidValidateMethod =
        validateMethodOverrides.isEmpty || validateMethodOverrides.length == 1;

    final isValid = isAbstract &&
        extendsFormBody &&
        hasNamelessFactoryConstructor &&
        hasPrivateConstructor &&
        hasValidValidateMethod;

    if (!isValid) {
      throw Exception(
        '''
The class "${classMetadata.name}" is not a valid form body.

Please make sure your form body class:
${isAbstract ? '✅' : '❌'} is abstract.
${extendsFormBody ? '✅' : '❌'} extends ${generatedClassNames.extendingFormBodyClassName}.
${hasNamelessFactoryConstructor ? '✅' : '❌'} has a nameless factory constructor that returns a "${generatedClassNames.generatedFormBodyClassName}".
${hasPrivateConstructor ? '✅' : '❌'} has a private const constructor ("const ${classMetadata.name}._()").
${hasValidValidateMethod ? '✅' : '❌'} has no validate method OR a single validate method that returns a "${generatedClassNames.generatedFormErrorsClassName}".

❗️❗️❗️
Additionally, make sure the form body class mixes in the ${generatedClassNames.generatedFormBodyFieldsMixinName} mixin.
❗️❗️❗️
''',
      );
    }
  }

  Future<ClientConstructorMetadata> _validateConstructors(
    Element element,
    BuildStep buildStep,
  ) async {
    final classMetadata = ClientClassMetadata.fromElement(element);
    final generatedClassNames =
        GeneratedClassNames(formBodyClassName: classMetadata.name);

    final constructors = await _getClientConstructorData(element, buildStep);

    if (constructors.isEmpty) {
      throw Exception(
        '''
No constructors found in class "${generatedClassNames.formBodyClassName}".
There must be exactly one factory constructor
that returns an instance of "${generatedClassNames.generatedFormBodyClassName}".''',
      );
    }

    final validConstructors =
        constructors.where((constructor) => constructor.isValid);

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

    final constructorBodies = [
      for (final constructorDeclarationNodes in constructorDeclarationNodes)
        _getConstructorBody(constructorDeclarationNodes)
    ];

    final constructorReturnStatements = [
      for (final constructorBody in constructorBodies)
        if (constructorBody == null)
          null
        else
          _getReturnStatement(constructorBody)
    ];

    final result = [
      for (var i = 0; i < classMetadata.constructors.length; i++)
        ClientConstructorMetadata(
          name: classMetadata.constructors[i].name,
          enclosingClass: classMetadata.constructors[i].returnType,
          isFactory: classMetadata.constructors[i].isFactory,
          returnStatement: constructorReturnStatements[i],
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
      final astNode =
          await buildStep.resolver.astNodeFor(constructor, resolve: true);
      final visitor = _ConstructorAstVisitor();
      astNode?.accept<dynamic>(visitor);
      if (visitor.node != null) {
        result.add(visitor.node!);
      }
    }

    return result;
  }

  BlockFunctionBody? _getConstructorBody(ConstructorDeclaration declaration) {
    for (final childEntity in declaration.childEntities) {
      if (childEntity is BlockFunctionBody) {
        return childEntity;
      }
    }

    return null;
  }

  ReturnStatement _getReturnStatement(BlockFunctionBody body) {
    for (final childEntity in body.block.statements) {
      if (childEntity is ReturnStatement) {
        return childEntity;
      }
    }

    throw Exception('No return statement found in body. "$body"');
  }

  Future<List<FormBodyFieldMetadata>> _getFormBodyFieldMetadata(
    Element element,
    BuildStep buildStep,
  ) async {
    final classMetadata = ClientClassMetadata.fromElement(element);
    final generatedClassNames =
        GeneratedClassNames(formBodyClassName: classMetadata.name);

    final constructorMetadata =
        await _getClientConstructorData(element, buildStep)
            .then((results) => results.firstWhere((c) => c.isValid));

    final returnStatement = constructorMetadata.returnStatement;

    // TODO(jeroen-meijer): Support identifiers and other value references
    final expression = returnStatement!.expression;
    if (expression is! MethodInvocation) {
      throw Exception(
        '''
No method invocation found in return statement.

-----------------------------------------------

shape_generator only supports return statements that are immediately followed
by a constructor invocation of the form body class.

Please make sure your return statement looks like the following:

  return ${generatedClassNames.generatedFormBodyClassName}(
    foo: FooFormField(
      value: 'abc',
    ),
    bar: BarFormField(
      value: 123,
    ),
  );

It is allowed, however, to refer to form fields by variable name, like the
following:

  final foo = FooFormField(value: 'abc');
  final bar = BarFormField(value: 123);

  return ${generatedClassNames.generatedFormBodyClassName}(
    foo: foo,
    bar: bar,
  );

-----------------------------------------------

Expression found was: "$expression".''',
      );
    }

    final invocation = expression;
    final generatedFormBodyClassName = invocation.methodName;
    assert(
      generatedFormBodyClassName.name ==
          constructorMetadata.returnStatementType.name,
    );
    assert(
      generatedFormBodyClassName.name ==
          generatedClassNames.generatedFormBodyClassName,
    );

    final result = <FormBodyFieldMetadata>[];

    final formBodyArguments = invocation.argumentList.arguments;

    for (var i = 0; i < formBodyArguments.length; i++) {
      final formBodyArgument = formBodyArguments[i];
      if (formBodyArgument is! NamedExpression) {
        throw Exception(
          '''
The argument at index $i in the "$generatedFormBodyClassName" construction
is not a named argument.

-----------------------------------------------

Please make sure that all arguments are named
parameters.

-----------------------------------------------

Argument found: "$formBodyArgument" (of type ${formBodyArgument.runtimeType})''',
        );
      }

      final formFieldIdentifier = formBodyArgument.name.label;
      if (formFieldIdentifier.name.startsWith('_')) {
        throw Exception(
          '''
The form field with name "$formFieldIdentifier" is not a valid identifier.

-----------------------------------------------

Form field names cannot be provided as a private parameter and can therefor
not start with an underscore.

-----------------------------------------------

Form field name found: "$formFieldIdentifier"''',
        );
      }

      final formFieldCreationExpression = formBodyArgument.expression;
      final formFieldExpressionType = formFieldCreationExpression.staticType;
      ClassElement? formFieldClassElement;

      final element = formFieldCreationExpression.staticType?.element;
      if (element is ClassElement) {
        formFieldClassElement = element;
      }

      if (formFieldClassElement == null) {
        throw Exception(
          '''
Could not determine the type of the form field with name "$formBodyArgument".
The form field is not a class or a simple identifier.

-----------------------------------------------

Make sure that you have imported all necessary libraries and that the referenced
form field exists.

-----------------------------------------------

If the form field declaration exists and has been imported, this should be
considered a bug in the shape_generator package. Please report it.

Expression found: $formFieldCreationExpression (with static type ${formFieldCreationExpression.staticType} and runtime type ${formFieldCreationExpression.runtimeType})''',
        );
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

-----------------------------------------------

You can try fixing this by explicitly defining the generic type arguments.
For example, when using a GenericFormField<T> for a String, the type for T can
be provided as follows:

  MyFormField(
    someField: GenericType<String>(...),
  )

-----------------------------------------------

If the above has already been done, this should be considered a bug in the
shape_generator package. Please report it.

Type parameters found: "${formFieldClassMetadata.typeParameters}" (length ${formFieldClassMetadata.typeParameters.length})
Instance type arguments found: "$instanceTypeArguments" (length ${instanceTypeArguments.length})''',
        );
      }

      final formBodyFieldMetadata = FormBodyFieldMetadata(
        fieldIdentifier: formFieldIdentifier,
        formClassMetadata: formFieldClassMetadata,
        genericTypeArguments: {
          for (var i = 0;
              i < formFieldClassMetadata.typeParameters.length;
              i++) ...{
            formFieldClassMetadata.typeParameters[i]: instanceTypeArguments[i],
          }
        },
      );

      result.add(formBodyFieldMetadata);
    }

    return result;
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
