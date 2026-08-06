/// Shared helpers for running [ShapeGenerator] in unit tests.
library;

import 'dart:isolate';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_config/package_config.dart';
import 'package:shape/shape.dart';
import 'package:shape_generator/src/generators/shape_generator.dart';
import 'package:source_gen/source_gen.dart';

class _MockBuildStep extends Mock implements BuildStep {}

Future<PackageConfig> workspacePackageConfigForTests() =>
    _workspacePackageConfig();

PackageConfig? _cachedPackageConfig;

Future<PackageConfig> _workspacePackageConfig() async {
  if (_cachedPackageConfig != null) {
    return _cachedPackageConfig!;
  }

  final packageConfigUri = await Isolate.packageConfig;
  if (packageConfigUri == null) {
    throw StateError('Could not find a package config for generator tests.');
  }

  _cachedPackageConfig = await loadPackageConfigUri(packageConfigUri);
  return _cachedPackageConfig!;
}

/// Minimal [FormField] used in generator test inputs.
const genericFormFieldSource = '''
class GenericFormField<T> extends FormField<T, T, GenericValidationError> {
  const GenericFormField(super.rawValue, {this.isRequired = false});

  @override
  T get value => rawValue;

  final bool isRequired;

  @override
  GenericValidationError? validate() {
    if (rawValue == null && isRequired) {
      return GenericValidationError.missing;
    }
    return null;
  }
}

enum GenericValidationError { missing }
''';

/// Builds a valid form body source string for [className].
String validFormBodySource({
  required String className,
  String? errorsClassName,
  String? generatedClassName,
  String? factoryBody,
  String factoryParams = 'required String? name',
}) {
  final generated = generatedClassName ?? '_\$$className';
  final body =
      factoryBody ??
      '''
    return $generated(
      name: name,
    );''';

  return '''
import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

part 'form_body.g.dart';

@GenerateFormBody()
abstract class $className extends FormBody with _\$${className}Fields {
  const $className._();

  factory $className({$factoryParams}) {
    $body
  }
}

$genericFormFieldSource
''';
}

/// Runs [ShapeGenerator] against synthetic [source] in `_resolve_source`.
Future<ShapeGeneratorTestResult> runShapeGenerator({
  required String source,
  String className = 'TestFormBody',
}) async {
  String? generated;
  Object? thrown;

  await resolveSources(
    {'_resolve_source|lib/_resolve_source.dart': source},
    (resolver) async {
      final library = await resolver.libraryFor(
        AssetId('_resolve_source', 'lib/_resolve_source.dart'),
      );
      final element = library.getClass(className);
      if (element == null) {
        throw StateError('Class "$className" not found in test source.');
      }

      final buildStep = _MockBuildStep();
      when(() => buildStep.resolver).thenReturn(resolver);
      when(
        () => buildStep.inputId,
      ).thenReturn(AssetId('_resolve_source', 'lib/_resolve_source.dart'));

      final generator = ShapeGenerator();
      try {
        generated = await generator.generateForAnnotatedElement(
          element,
          ConstantReader(_annotationObject(element)),
          buildStep,
        );
      } on Object catch (error) {
        thrown = error;
      }
    },
    packageConfig: await _workspacePackageConfig(),
    readAllSourcesFromFilesystem: true,
  );

  return ShapeGeneratorTestResult(generated: generated, thrown: thrown);
}

DartObject _annotationObject(ClassElement element) {
  final annotation = const TypeChecker.typeNamed(
    GenerateFormBody,
    inPackage: 'shape',
  ).firstAnnotationOfExact(element);
  if (annotation == null) {
    throw StateError('Class "${element.name}" is missing @GenerateFormBody.');
  }
  return annotation;
}

/// Result of [runShapeGenerator].
class ShapeGeneratorTestResult {
  const ShapeGeneratorTestResult({
    required this.generated,
    required this.thrown,
  });

  final String? generated;
  final Object? thrown;

  bool get succeeded => thrown == null && generated != null;

  String get failureOutput {
    if (thrown != null) {
      return thrown.toString();
    }
    return generated ?? '';
  }
}

/// Asserts that generation fails and output contains [message].
void expectGenerationFailure(ShapeGeneratorTestResult result, String message) {
  if (result.succeeded) {
    throw TestFailure(
      'Expected generation to fail, but it succeeded.\n'
      'Generated:\n${result.generated}',
    );
  }

  if (!result.failureOutput.contains(message)) {
    throw TestFailure(
      'Expected failure output to contain:\n$message\n\n'
      'Actual output:\n${result.failureOutput}',
    );
  }
}

/// Minimal test failure type so this library does not depend on `package:test`.
class TestFailure implements Exception {
  TestFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
