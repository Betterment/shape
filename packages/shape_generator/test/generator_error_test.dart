import 'package:test/test.dart' hide expect;

import 'support/shape_generator_test_harness.dart';

void main() {
  group('invalid form body declarations', () {
    test('rejects non-abstract classes', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(className: 'ConcreteFormBody').replaceFirst(
          'abstract class ConcreteFormBody',
          'class ConcreteFormBody',
        ),
        className: 'ConcreteFormBody',
      );

      expectGenerationFailure(result, 'is abstract');
    });

    test('rejects classes that do not extend FormBody', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(className: 'PlainFormBody').replaceFirst(
          'extends FormBody with _\$PlainFormBodyFields',
          'with _\$PlainFormBodyFields implements Object',
        ),
        className: 'PlainFormBody',
      );

      expectGenerationFailure(result, 'extends FormBody');
    });

    test('rejects missing factory constructor', () async {
      final result = await runShapeGenerator(
        source:
            '''
import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

part 'form_body.g.dart';

@GenerateFormBody()
abstract class MissingFactoryFormBody extends FormBody {}

$genericFormFieldSource
''',
        className: 'MissingFactoryFormBody',
      );

      expectGenerationFailure(result, 'nameless factory constructor');
    });
  });

  group('invalid factory bodies', () {
    test('rejects positional constructor arguments', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'PositionalArgsFormBody',
          factoryBody: '''
    return _\$PositionalArgsFormBody(name);''',
        ),
        className: 'PositionalArgsFormBody',
      );

      expectGenerationFailure(result, 'not a named argument');
    });

    test('rejects private field names', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'PrivateFieldFormBody',
          factoryBody: '''
    return _\$PrivateFieldFormBody(
      _secret: name,
    );''',
          factoryParams: 'required String? name, required String? _secret',
        ),
        className: 'PrivateFieldFormBody',
      );

      expectGenerationFailure(result, 'not a valid identifier');
    });

    test('rejects factories returning the wrong generated class', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'WrongReturnTypeFormBody',
          factoryBody: '''
    return WrongClass(
      name: name,
    );''',
        ),
        className: 'WrongReturnTypeFormBody',
      );

      expectGenerationFailure(
        result,
        'No valid constructors found in class "WrongReturnTypeFormBody"',
      );
    });

    test('rejects multiple valid factory constructors', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(className: 'DualFactoryFormBody')
            .replaceFirst(
              'factory DualFactoryFormBody({required String? name}) {',
              '''
  factory DualFactoryFormBody.alt({required String? name}) {
    return _\$DualFactoryFormBody(
      name: name,
    );
  }

  factory DualFactoryFormBody({required String? name}) {''',
            ),
        className: 'DualFactoryFormBody',
      );

      expectGenerationFailure(
        result,
        'Multiple valid constructors found in class "DualFactoryFormBody"',
      );
    });
  });
}
