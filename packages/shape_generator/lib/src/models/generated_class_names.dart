import 'package:equatable/equatable.dart';
import 'package:shape_generator/src/models/models.dart';

/// {@template generated_class_names}
/// A model that contains the strings for generated classes, mixins and other
/// models.
/// {@endtemplate}
class GeneratedClassNames extends Equatable {
  /// {@macro generated_class_names}
  const GeneratedClassNames({required this.formBodyClassName});

  /// The name of the form body class the generator is currently parsing.
  final String formBodyClassName;

  /// The name of the generated private form body class.
  String get generatedFormBodyClassName =>
      '$kGeneratedClassPrefix$formBodyClassName';

  /// The name of the generated private form body fields mixin.
  String get generatedFormBodyFieldsMixinName =>
      '$kGeneratedClassPrefix$formBodyClassName$kGeneratedFieldsMixinSuffix';

  /// The name of the generated form errors class.
  String get generatedFormErrorsClassName {
    var indexOfBodyPart = formBodyClassName.lastIndexOf('Body');
    if (indexOfBodyPart == -1) {
      indexOfBodyPart = formBodyClassName.length;
    }
    final truncated = formBodyClassName.substring(0, indexOfBodyPart);
    return '${truncated}Errors';
  }

  /// The name of the private CopyWith class interface for the form body.
  String get generatedCopyWithClassName =>
      '${generatedFormBodyClassName}CopyWith';

  /// The name of the private CopyWith class implementation for the form body.
  String get generatedCopyWithImplClassName =>
      '${generatedCopyWithClassName}Impl';

  /// The name of the private CopyWith class interface for the form errors.
  String get generatedErrorsCopyWithClassName =>
      '_${generatedFormErrorsClassName}CopyWith';

  /// The name of the private CopyWith class implementation for the form errors.
  String get generatedErrorsCopyWithImplClassName =>
      '${generatedErrorsCopyWithClassName}Impl';

  /// The name of the interface that the implementing form body class should
  /// extend.
  String get extendingFormBodyClassName =>
      '$kFormBodyBaseClassName<$generatedFormErrorsClassName>';

  @override
  List<Object?> get props => [formBodyClassName];
}
