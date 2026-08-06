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

    test('preserves explicit custom FormField wrappers', () async {
      final result = await runShapeGenerator(
        source: validFormBodySource(
          className: 'CustomWrapperFormBody',
          factoryParams: 'required String? name',
          factoryBody: '''
    return _\$CustomWrapperFormBody(
      name: GenericFormField(name, isRequired: true),
    );''',
        ),
        className: 'CustomWrapperFormBody',
      );

      check(result.succeeded).isTrue();
      // Custom wrappers become typed factory params; the call site expression is
      // not re-emitted into the generated factory body.
      check(result.generated!).contains(
        'required GenericFormField<String?> name',
      );
      check(
        result.generated!.contains(
          'GenericFormField<String?>(name, isRequired: true)',
        ),
      ).isFalse();
    });

    test('supports redirecting factory constructors', () async {
      final result = await runShapeGenerator(
        source:
            '''
import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

part 'form_body.g.dart';

@GenerateFormBody()
abstract class RedirectFormBody extends FormBody with _\$RedirectFormBodyFields {
  const RedirectFormBody._();

  factory RedirectFormBody({@FieldRequired() String? name}) = _\$RedirectFormBody;
}

$genericFormFieldSource
''',
        className: 'RedirectFormBody',
      );

      check(result.succeeded).isTrue();
      check(result.generated!).contains('class _\$RedirectFormBody');
      check(result.generated!).contains(
        'GenericFormField<String?>(name, isRequired: true)',
      );
    });
  });
}
