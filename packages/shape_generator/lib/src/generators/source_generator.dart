import 'package:meta/meta.dart';

/// {@template function_parameter}
/// A model representing a single parameter in a function or constructor call.
///
/// Depending on the context, the [isRequired] parameter may be ignored.
/// {@endtemplate}
class FunctionParameter {
  /// {@macro function_parameter}
  const FunctionParameter({
    required this.type,
    required this.name,
    this.defaultValue,
    this.isRequired = false,
  })  : assert(name.length > 0),
        assert(type.length > 0);

  /// The type of the parameter.
  final String type;

  /// The name of the parameter.
  final String name;

  /// The optional default value of the parameter.
  final String? defaultValue;

  /// Whether or not the parameter is required.
  final bool isRequired;
}

/// {@template source_generator}
/// A class that wraps a [StringBuffer] to make generating source code easier.
///
/// Contains many methods used to generate parts of common Dart source code.
/// {@endtemplate}
abstract class SourceGenerator {
  /// {@macro source_generator}
  SourceGenerator();

  final _buffer = StringBuffer();

  /// The function that generates the source code using instructions available
  /// in this class.
  ///
  /// This should be overridden by subclasses.
  String generate();

  /// Outputs the current contents of the buffer.
  ///
  /// This should **not** be overridden by subclasses, as it's used to generate
  /// the final source code.
  @nonVirtual
  String generateSource() {
    return _buffer.toString();
  }

  String get _required => 'required';

  List<String> _removeEmptyLeadingAndTrailingLines(List<String> lines) {
    return lines
        // Remove leading empty lines.
        .skipWhile((line) => line.trim().isEmpty)
        .toList()
        // Reverse list and remove trailing empty lines.
        .reversed
        .skipWhile((line) => line.trim().isEmpty)
        .toList()
        // Reverse back to original order.
        .reversed
        .toList();
  }

  /// Writes [object] followed by a newline, "\n".
  void _writeln([Object? obj = '']) {
    _buffer.writeln(obj);
  }

  void _writeDocumentation(String documentation) {
    if (documentation.trim().isEmpty) {
      return;
    }

    final lines =
        _removeEmptyLeadingAndTrailingLines(documentation.split('\n'));

    for (var line in lines) {
      if (line.trim().isEmpty) {
        line = line.trim();
      }
      _writeln('/// ${line.trimRight()}');
    }
  }

  /// Writes a line with the override annotation (`@override`).
  void writeOverrideAnnotation() {
    _writeln('@override');
  }

  /// Writes a line with the immutable annotation (`@immutable`).
  void writeImmutableAnnotation() {
    _writeln('@immutable');
  }

  /// Writes a multi-line comment.
  void writeComment(String comment) {
    if (comment.trim().isEmpty) {
      return;
    }

    final lines = _removeEmptyLeadingAndTrailingLines(comment.split('\n'));

    for (var line in lines) {
      if (line.trim().isEmpty) {
        line = line.trim();
      }
      _writeln('// ${line.trimRight()}');
    }
  }

  /// Writes the signature for a function.
  ///
  /// Can be used to write full functions, or just the signature for use in an
  /// abstract class or mixin. When doing so, do not forget to append a `;` to
  /// the end of the signature.
  void writeFunctionSignature({
    String documentation = '',
    required String returnType,
    required String functionName,
    List<FunctionParameter> parameters = const [],
    bool isOverride = false,
  }) {
    _writeDocumentation(documentation);

    if (isOverride) {
      writeOverrideAnnotation();
    }
    if (parameters.isEmpty) {
      _writeln('$returnType $functionName()');
    } else {
      _writeln('$returnType $functionName({');
      for (final parameter in parameters) {
        final defaultValueClause = parameter.defaultValue == null
            ? ''
            : ' = ${parameter.defaultValue}';
        if (parameter.isRequired) {
          _writeln(
            '''$_required ${parameter.type} ${parameter.name}$defaultValueClause,''',
          );
        } else {
          _writeln('${parameter.type} ${parameter.name}$defaultValueClause,');
        }
      }
      _writeln('})');
    }
  }

  /// Writes the start of a class declaration with the given [name].
  ///
  /// Optionally, the [extendedClass], [mixins] and [implementedInterfaces]
  /// can also be provided.
  void writeClassDeclarationStart({
    String documentation = '',
    required String name,
    bool isAbstract = false,
    String? extendedClass,
    List<String> mixins = const [],
    List<String> implementedInterfaces = const [],
  }) {
    _writeDocumentation(documentation);

    if (isAbstract) {
      _writeln('abstract');
    }
    _writeln('class $name ');
    if (extendedClass != null) {
      _writeln('extends $extendedClass ');
    }
    if (mixins.isNotEmpty) {
      _writeln('with ${mixins.join(', ')} ');
    }
    if (implementedInterfaces.isNotEmpty) {
      _writeln('implements ${implementedInterfaces.join(', ')}');
    }
    _writeln('{');
  }

  /// Writes the end of a class declaration.
  void writeClassDeclarationEnd() {
    _writeln('}');
  }

  /// Writes a factory method that internally calls the provided constructor
  /// `Foo.constructorName(...)`.
  void writeClassFactoryConstructor({
    String documentation = '',
    required String className,
    String factoryName = '',
    String constructorName = '_',
    List<FunctionParameter> parameters = const [],
  }) {
    final fullFactoryName =
        factoryName.isEmpty ? className : '$className.$factoryName';
    final parameterNames = parameters.map((p) => p.name);

    writeSingleReturnFunction(
      documentation: documentation,
      returnType: 'factory',
      functionName: fullFactoryName,
      parameters: parameters,
      returnValue: '$className.$constructorName(${parameterNames.join(', ')})',
    );
  }

  /// Writes a constructor method with positional or named parameters.
  ///
  /// When [useNamedParameters] is `true`, all parameters cannot be private
  /// (i.e., start with an `_`).
  void writeClassConstructor({
    String documentation = '',
    required String className,
    String constructorName = '',
    List<FunctionParameter> parameters = const [],
    bool useConstConstructor = true,
    bool useNamedParameters = false,
    String? supertypeConstructorName,
    bool passParametersToSuper = false,
  }) {
    assert(
      !useNamedParameters || parameters.every((p) => !p.name.startsWith('_')),
      'Cannot provide private parameters '
      'for a constructor with named parameters.',
    );

    _writeDocumentation(documentation);

    final fullConstructorName =
        constructorName.isEmpty ? className : '$className.$constructorName';
    final privateInstanceParameterNames =
        parameters.map((p) => 'this.${p.name},');
    if (!useNamedParameters) {
      if (useConstConstructor) {
        _writeln(
          'const $fullConstructorName(${privateInstanceParameterNames.join()})',
        );
      } else {
        _writeln(
          '$fullConstructorName(${privateInstanceParameterNames.join()})',
        );
      }
    } else {
      if (useConstConstructor) {
        _writeln('const $fullConstructorName({');
      } else {
        _writeln('$fullConstructorName({');
      }
      for (final parameter in parameters) {
        if (parameter.isRequired) {
          _writeln('$_required this.${parameter.name},');
        } else {
          _writeln('this.${parameter.name},');
        }
      }
      _writeln('})');
    }

    if (supertypeConstructorName != null) {
      _writeln(
        // ignore: missing_whitespace_between_adjacent_strings
        ''' : super.$supertypeConstructorName(${!passParametersToSuper ? '' : privateInstanceParameterNames.join()})''',
      );
    }

    _writeln(';');
  }

  /// Writes a class field of the given [type] with the given [name].
  void writeClassField({
    String documentation = '',
    required String type,
    required String name,
    bool isFinal = true,
    bool isOverride = false,
  }) {
    _writeDocumentation(documentation);

    if (isOverride) {
      writeOverrideAnnotation();
    }
    if (isFinal) {
      _writeln('final $type $name;');
    } else {
      _writeln('$type $name;');
    }
  }

  /// Writes a static const variable with the given [name] and [value].
  void writeStaticConstClassField({
    String documentation = '',
    required String name,
    required String value,
  }) {
    _writeDocumentation(documentation);
    _writeln('static const $name = $value;');
  }

  /// Writes a getter of the given [type] with the given [name].
  void writeClassGetter({
    String documentation = '',
    required String type,
    required String name,
    required String value,
    bool isOverride = false,
  }) {
    _writeDocumentation(documentation);

    if (isOverride) {
      writeOverrideAnnotation();
    }
    _writeln('$type get $name => $value;');
  }

  /// Writes a class getter function without a body (mainly for use in abstract
  /// classes and interfaces).
  void writeBodylessClassGetter({
    String documentation = '',
    required String type,
    required String name,
  }) {
    _writeDocumentation(documentation);
    _writeln('$type get $name ;');
  }

  /// Writes a function signature without a body (mainly for use in abstract
  /// classes and interfaces).
  void writeBodylessFunction({
    String documentation = '',
    required String returnType,
    required String functionName,
    List<FunctionParameter> parameters = const [],
  }) {
    writeFunctionSignature(
      documentation: documentation,
      returnType: returnType,
      functionName: functionName,
      parameters: parameters,
      isOverride: false,
    );
    _writeln(';');
  }

  /// Writes the start of a function including its signature and an opening body
  /// tag (`{`).
  void writeFunctionStart({
    String documentation = '',
    required String returnType,
    required String functionName,
    List<FunctionParameter> parameters = const [],
    bool isOverride = false,
  }) {
    writeFunctionSignature(
      documentation: documentation,
      returnType: returnType,
      functionName: functionName,
      parameters: parameters,
      isOverride: isOverride,
    );
    _writeln(' {');
  }

  /// Writes the closing body tag of a function (`}`).
  void writeFunctionEnd() {
    _writeln('}');
  }

  /// Writes a simple function that immediately returns the given [returnValue].
  void writeSingleReturnFunction({
    String documentation = '',
    required String returnType,
    required String functionName,
    List<FunctionParameter> parameters = const [],
    required String returnValue,
    bool isOverride = false,
  }) {
    writeFunctionStart(
      documentation: documentation,
      returnType: returnType,
      functionName: functionName,
      parameters: parameters,
      isOverride: isOverride,
    );
    _writeln('return $returnValue;');
    writeFunctionEnd();
  }

  /// Writes a function that copies this instance of [className] but overwrites
  /// any of its fields with the given [parameters].
  ///
  /// The [parameters] are always nullable and named.
  ///
  /// Optionally, a [internalParameterSelector] can be provided to change the
  /// way fallback values are selected when no parameter is provided in the
  /// method call. If `null`, a default function will be used that simply
  /// returns `(String p) => 'this.$p'`, since this is a common use-case for
  /// `copyWith` methods.
  void writeCopyWithMethod({
    String documentation = '',
    required String className,
    String methodName = 'copyWith',
    List<FunctionParameter> parameters = const [],
    String Function(FunctionParameter parameter)? internalParameterSelector,
    bool isOverride = false,
  }) {
    final selectInternalParam =
        internalParameterSelector ?? (p) => 'this.${p.name}';
    writeFunctionStart(
      documentation: documentation,
      returnType: className,
      functionName: methodName,
      parameters: parameters,
      isOverride: isOverride,
    );
    _writeln('return $className(');
    for (final parameter in parameters) {
      final name = parameter.name;
      _writeln('  $name: $name ?? ${selectInternalParam(parameter)},');
    }
    _writeln(');');
    writeFunctionEnd();
  }

  /// Writes the start of a `mixin` declaration.
  void writeMixinDeclarationStart({
    String documentation = '',
    required String name,
  }) {
    _writeDocumentation(documentation);
    _writeln('mixin $name {');
  }

  /// Writes the end of a `mixin` declaration.
  void writeMixinDeclarationEnd() {
    _writeln('}');
  }
}
