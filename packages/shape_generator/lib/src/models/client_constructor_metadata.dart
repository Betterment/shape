import 'package:analyzer/dart/ast/ast.dart';
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
    required this.returnStatement,
  });

  /// The name of the constructor.
  final String name;

  /// The class that the constructor is a member of.
  final DartType enclosingClass;

  /// Indicates whether the constructor is a factory constructor.
  final bool isFactory;

  /// The return statement of the constructor.
  final ReturnStatement? returnStatement;

  GeneratedClassNames get _classNames => GeneratedClassNames(
    formBodyClassName: enclosingClass.nonNullableDisplayString,
  );

  /// The return type of the return statement.
  SimpleIdentifier get returnStatementType {
    if (returnStatement?.expression is MethodInvocation) {
      return (returnStatement!.expression! as MethodInvocation).methodName;
    }

    throw Exception(
      'Expression following return statement was not a method invocation.',
    );
  }

  /// Indicates whether the constructor is unnamed.
  bool get isUnnamed => name.isEmpty;

  /// Indicates whether the [returnStatementType]'s name is the name of the
  /// [enclosingClass], prepended with `_$` (the [kGeneratedClassPrefix]).
  ///
  /// For example, if the enclosing class is `Foo`, the return statement type
  /// should be `_$Foo`, in which case this will be `true`.
  bool get hasValidReturnStatementType =>
      returnStatementType.name == _classNames.generatedFormBodyClassName;

  /// Indicates whether the constructor is valid.
  bool get isValid =>
      isFactory &&
      returnStatement?.expression is MethodInvocation &&
      hasValidReturnStatementType;

  @override
  String toString() {
    return 'ClientConstructorMetadata('
        'name: $name, '
        'enclosingClass: $enclosingClass, '
        'isFactory: $isFactory, '
        'returnStatementType: $returnStatementType'
        ')';
  }
}
