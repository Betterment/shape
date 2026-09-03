import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/models/models.dart';

/// {@template client_constructor_metadata}
/// Metadata about a constructor or factory method in the client codebase.
/// {@endtemplate}
class ClientConstructorMetadata {
  /// {@macro client_constructor_metadata}
  const ClientConstructorMetadata({
    required this.name,
    required this.enclosingClass,
    required this.isFactory,
    required this.returnExpression,
    this.redirectTarget,
    this.redirectTargetName,
  });

  /// The name of the constructor.
  final String name;

  /// The class that the constructor is a member of.
  final DartType enclosingClass;

  /// Indicates whether the constructor is a factory constructor.
  final bool isFactory;

  /// The expression returned from the constructor.
  final Expression? returnExpression;

  /// The constructor target for a redirecting factory constructor.
  final ConstructorElement? redirectTarget;

  /// The redirect target class name from source, when [redirectTarget] is
  /// unresolved.
  final String? redirectTargetName;

  GeneratedClassNames get _classNames => GeneratedClassNames(
    formBodyClassName: enclosingClass.nonNullableDisplayString,
  );

  /// The name of the type returned from the constructor.
  String get returnExpressionTypeName {
    if (redirectTarget != null) {
      return redirectTarget!.enclosingElement.name ?? '';
    }
    if (redirectTargetName != null) {
      return redirectTargetName!;
    }

    final expression = returnExpression;
    if (expression is MethodInvocation) {
      return expression.methodName.name;
    }
    if (expression is InstanceCreationExpression) {
      return expression.constructorName.name?.name ??
          expression.constructorName.type.name.lexeme;
    }

    throw Exception(
      'Expression following return statement was not a constructor invocation.',
    );
  }

  /// Indicates whether the constructor is unnamed.
  ///
  /// Analyzer 14 reports the unnamed constructor name as `new`.
  bool get isUnnamed => name.isEmpty || name == 'new';

  /// Indicates whether [returnExpressionTypeName] is the name of the
  /// [enclosingClass], prepended with `_$` (the [kGeneratedClassPrefix]).
  bool get hasValidReturnStatementType =>
      returnExpressionTypeName == _classNames.generatedFormBodyClassName;

  /// Indicates whether the constructor is valid.
  bool get isValid =>
      isFactory &&
      (redirectTarget != null ||
          redirectTargetName != null ||
          returnExpression is MethodInvocation ||
          returnExpression is InstanceCreationExpression) &&
      hasValidReturnStatementType;

  @override
  String toString() {
    return 'ClientConstructorMetadata('
        'name: $name, '
        'enclosingClass: $enclosingClass, '
        'isFactory: $isFactory, '
        'returnExpressionTypeName: $returnExpressionTypeName'
        ')';
  }
}
