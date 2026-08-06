import 'package:checks/checks.dart';
import 'package:test/test.dart' hide expect;

import 'support/shape_generator_test_harness.dart';

void main() {
  group('successful generation', () {
    test('generates a minimal valid form body', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(className: 'MinimalFormBody'),
        className: 'MinimalFormBody',
      );

      check(result.succeeded).isTrue();
      check(result.generated!).contains('class _\$MinimalFormBody');
      check(result.generated!).contains('MinimalFormErrors');
    });

    test('wraps plain factory parameters in GenericFormField', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'GenericFormBody',
          factoryParams: '@FieldRequired() Object? value',
          factoryBody: '''
    return _\$GenericFormBody(
      value: value,
    );''',
        ),
        className: 'GenericFormBody',
      );

      check(result.succeeded).isTrue();
      check(
        result.generated!,
      ).contains('GenericFormField<Object?>(value, isRequired: true)');
    });

    test('generates without form errors when disabled', () async {
      final result = await runShapeGenerator(
        source:
            '''
import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

part 'form_body.g.dart';

@GenerateFormBody(generateFormErrors: false)
abstract class NoErrorsFormBody extends FormBody with _\$NoErrorsFormBodyFields {
  const NoErrorsFormBody._();

  factory NoErrorsFormBody({required String? name}) =>
      _\$NoErrorsFormBody(name: name);
}

$genericFormFieldSource
''',
        className: 'NoErrorsFormBody',
      );

      check(result.succeeded).isTrue();
      check(result.generated!.contains('class NoErrorsErrors')).isFalse();
    });
  });
}
