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
        source: validFormBodySource(
          className: 'PlainFormBody',
        ).replaceFirst('extends FormBody<PlainFormErrors>\n    ', ''),
        className: 'PlainFormBody',
      );

      expectGenerationFailure(result, 'extends FormBody');
    });

    test('rejects missing private constructor', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'MissingPrivateCtorFormBody',
        ).replaceFirst('\n  const MissingPrivateCtorFormBody._();\n', '\n'),
        className: 'MissingPrivateCtorFormBody',
      );

      expectGenerationFailure(result, 'private const constructor');
    });

    test('rejects missing factory constructor', () async {
      final result = await runShapeGenerator(
        source:
            '''
import 'package:shape/shape.dart';

part 'form_body.g.dart';

@GenerateFormBody()
abstract class MissingFactoryFormBody extends FormBody<MissingFactoryErrors>
    with _\$MissingFactoryFormBodyFields {
  const MissingFactoryFormBody._();
}

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
    return _\$PositionalArgsFormBody(
      GenericFormField<String?>(name, isRequired: true),
    );''',
        ),
        className: 'PositionalArgsFormBody',
      );

      expectGenerationFailure(result, 'is not a named argument');
    });

    test('rejects private field names', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'PrivateFieldFormBody',
          factoryBody: '''
    return _\$PrivateFieldFormBody(
      _secret: GenericFormField<String?>(name, isRequired: true),
    );''',
        ),
        className: 'PrivateFieldFormBody',
      );

      expectGenerationFailure(result, 'not a valid identifier');
    });

    test('rejects indirect factory return expressions', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'BadReturnFormBody',
          factoryBody: '''
    final body = _\$BadReturnFormBody(
      name: GenericFormField<String?>(name, isRequired: true),
    );
    return body;''',
        ),
        className: 'BadReturnFormBody',
      );

      expectGenerationFailure(
        result,
        'No valid constructors found in class "BadReturnFormBody"',
      );
    });

    test('rejects factories returning the wrong generated class', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'WrongReturnTypeFormBody',
          factoryBody: '''
    return WrongClass(
      name: GenericFormField<String?>(name, isRequired: true),
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
            .replaceFirst('const DualFactoryFormBody._();', '''
  factory DualFactoryFormBody.alt({required String? name}) {
    return _\$DualFactoryFormBody(
      name: GenericFormField<String?>(name),
    );
  }

  const DualFactoryFormBody._();'''),
        className: 'DualFactoryFormBody',
      );

      expectGenerationFailure(
        result,
        'Multiple valid constructors found in class "DualFactoryFormBody"',
      );
    });
  });
}
