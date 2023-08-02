import 'package:checks/checks.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';
import 'package:test/test.dart' hide expect;

void main() {
  group('GenericFormField', () {
    GenericFormField<String?> buildSubject({
      String? value = '',
      bool isRequired = false,
    }) {
      return GenericFormField<String?>(
        value,
        isRequired: isRequired,
      );
    }

    test('can be constructed', () {
      check(buildSubject).returnsNormally().isA<GenericFormField<String?>>();
    });

    group('value', () {
      test('returns given input', () {
        check(buildSubject(value: 'Hello, world!'))
            .has((f) => f.value, 'value')
            .equals('Hello, world!');
      });
    });

    group('validate', () {
      test('returns no errors when input is not null', () {
        check(buildSubject(value: 'Hello, world!').validate)
            .returnsNormally()
            .isNull();
      });

      test('returns no errors when input is null and field is not required',
          () {
        check(
          buildSubject(
            value: null,
            isRequired: false,
          ).validate,
        ).returnsNormally().isNull();
      });

      test(
        'returns GenericValidationError.missing '
        'when input is null and field is required',
        () {
          check(
            buildSubject(
              value: null,
              isRequired: true,
            ).validate,
          )
              .returnsNormally()
              .isNotNull()
              .isA<GenericValidationError>()
              .equals(GenericValidationError.missing);
        },
      );
    });
  });
}
