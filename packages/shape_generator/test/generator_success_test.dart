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
      // Custom wrappers become typed factory params; the call site expression
      // is not re-emitted into the generated factory body.
      check(
        result.generated!,
      ).contains('required GenericFormField<String?> name');
      check(
        result.generated!.contains(
          'GenericFormField<String?>(name, isRequired: true)',
        ),
      ).isFalse();
    });

    test('marks non-nullable custom FormField params as required '
        'even when the raw factory params are optional', () async {
      final result = await runShapeGenerator(
        source: '''
import 'package:shape/shape.dart';

part 'form_body.g.dart';

@GenerateFormBody()
abstract class OptionalRawCustomWrapperFormBody extends FormBody
    with _\$OptionalRawCustomWrapperFormBodyFields {
  const OptionalRawCustomWrapperFormBody._();

  factory OptionalRawCustomWrapperFormBody({
    String? firstName,
    String? lastName,
    required bool requireNames,
  }) =>
      _\$OptionalRawCustomWrapperFormBody(
        firstName: TrimmedStringFormField(
          rawValue: firstName,
          isRequired: requireNames,
        ),
        lastName: TrimmedStringFormField(
          rawValue: lastName,
          isRequired: requireNames,
        ),
      );
}

class TrimmedStringFormField extends SimpleFormField<String?, Object?> {
  const TrimmedStringFormField({
    required String? rawValue,
    this.isRequired = false,
  }) : super(rawValue);

  final bool isRequired;

  @override
  String? get value => rawValue?.trim();

  @override
  Object? validate() {
    if (isRequired && (rawValue == null || rawValue!.trim().isEmpty)) {
      return 'missing';
    }
    return null;
  }
}
''',
        className: 'OptionalRawCustomWrapperFormBody',
      );

      check(result.succeeded).isTrue();
      check(
        result.generated!,
      ).contains('required TrimmedStringFormField firstName');
      check(
        result.generated!,
      ).contains('required TrimmedStringFormField lastName');
      // requireNames is only used when constructing wrappers in the user
      // factory; it must not become a generated form field.
      check(result.generated!.contains('requireNames')).isFalse();
      // copyWith must call the generated factory with FormField instances so
      // user-factory-only params like requireNames are not required.
      check(result.generated!).contains('_\$OptionalRawCustomWrapperFormBody(');
      check(result.generated!).contains(
        '? _instance._firstName : firstName! as TrimmedStringFormField',
      );
      check(result.generated!).contains('ignore_for_file: unused_element');
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
      check(
        result.generated!,
      ).contains('GenericFormField<String?>(name, isRequired: true)');
    });
  });
}
