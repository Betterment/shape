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

    test('supports generic form field type parameters', () async {
      const genericField = '''
class NullableFormField<T> extends FormField<T?, T?, GenericValidationError> {
  NullableFormField({required T? rawValue}) : super(rawValue);

  @override
  T? get value => rawValue;

  @override
  GenericValidationError? validate() => null;
}
''';

      final result = await runShapeGenerator(
        source:
            validFormBodySource(
              className: 'GenericFormBody',
              factoryParams: 'required Object? value',
              factoryBody: '''
    return _\$GenericFormBody(
      value: NullableFormField<Object?>(rawValue: value),
    );''',
            ).replaceFirst(
              genericFormFieldSource,
              '$genericFormFieldSource\n$genericField',
            ),
        className: 'GenericFormBody',
      );

      check(result.succeeded).isTrue();
      check(result.generated!).contains('NullableFormField<Object?> value');
    });

    test('generates without form errors when disabled', () async {
      final result = await runShapeGenerator(
        source:
            '''
import 'package:shape/shape.dart';

part 'form_body.g.dart';

@GenerateFormBody(generateFormErrors: false)
abstract class NoErrorsFormBody extends FormBody<Never>
    with _\$NoErrorsFormBodyFields {
  factory NoErrorsFormBody({required String? name}) {
    return _\$NoErrorsFormBody(
      name: GenericFormField<String?>(name),
    );
  }

  const NoErrorsFormBody._();
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
