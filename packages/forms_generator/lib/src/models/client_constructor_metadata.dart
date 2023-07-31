import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:forms_generator/src/extensions/extensions.dart';
import 'package:forms_generator/src/models/models.dart';

/// Metadata about a constructor or factory method in the client codebase.
class ClientConstructorMetadata {
  const ClientConstructorMetadata({
    required this.name,
    required this.enclosingClass,
    required this.isFactory,
    required this.returnStatement,
  });

  final String name;
  final DartType enclosingClass;
  final bool isFactory;
  final ReturnStatement? returnStatement;

  GeneratedClassNames get _classNames => GeneratedClassNames(
        formBodyClassName: enclosingClass.nonNullableDisplayString,
      );

  SimpleIdentifier get returnStatementType {
    if (returnStatement?.expression is MethodInvocation) {
      return (returnStatement!.expression! as MethodInvocation).methodName;
    }

    throw Exception(
      'Expression following return statement was not a method invocation.',
    );
  }

  bool get isUnnamed => name.isEmpty;

  /// Indicates whether the [returnStatementType]'s name is the name of the
  /// [enclosingClass], prepended with `_$` (the [kGeneratedClassPrefix]).
  ///
  /// For example, if the enclosing class is `Foo`, the return statement type
  /// should be `_$Foo`, in which case this will be `true`.
  bool get hasValidReturnStatementType =>
      returnStatementType.name == _classNames.generatedFormBodyClassName;

  bool get isValid =>
      isFactory &&
      returnStatement?.expression is MethodInvocation &&
      hasValidReturnStatementType;

  @override
  String toString() {
    return 'ClientConstructorMetadata(name: $name, enclosingClass: $enclosingClass, isFactory: $isFactory, returnStatementType: $returnStatementType)';
  }
}
