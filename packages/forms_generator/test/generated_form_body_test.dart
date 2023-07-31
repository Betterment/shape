import 'package:test/test.dart';

import 'fixtures/fixtures.dart';

void main() {
  group('Generated Form Body', () {
    TestFormBody buildSubject({
      required String stringField,
      required String intField,
      required Object? nullableField,
    }) {
      return TestFormBody(
        stringField: stringField,
        intField: intField,
        nullableField: nullableField,
      );
    }

    test('constructor works properly', () {
      expect(
        () => buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: null,
        ),
        returnsNormally,
      );
    });

    test('supports value equality', () {
      expect(
        buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: const Object(),
        ),
        buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: const Object(),
        ),
      );
    });

    test('field getters return parsed values', () {
      final subject = buildSubject(
        stringField: 'abc',
        intField: '123',
        nullableField: const Object(),
      );

      expect(subject.stringField, 'abc');
      expect(subject.intField, 123);
      expect(subject.nullableField, const Object());
    });

    group('validate', () {
      test('returns a generated form errors instance', () {
        expect(
          buildSubject(
            stringField: 'abc',
            intField: '123',
            nullableField: const Object(),
          ).validate(),
          isA<TestFormErrors>(),
        );
      });

      test('validates all fields', () {
        expect(
          buildSubject(
            stringField: 'abc',
            intField: '123',
            nullableField: const Object(),
          ).validate(),
          const TestFormErrors(),
        );

        expect(
          buildSubject(
            stringField: '',
            intField: 'abc',
            nullableField: null,
          ).validate(),
          const TestFormErrors(
            stringField: TestValidationError.empty,
            intField: TestValidationError.empty,
            nullableField: TestValidationError.empty,
          ),
        );
      });
    });

    group('copyWith', () {
      test('copies object with specified fields replaced', () {
        final subject = buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: const Object(),
        );
        final actual = subject.copyWith(stringField: 'def');
        final expected = buildSubject(
          stringField: 'def',
          intField: '123',
          nullableField: const Object(),
        );

        expect(actual, expected);
      });

      test('supports explicitly setting nullable fields to null', () {
        final subject = buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: 'xyz',
        );
        final actual = subject.copyWith(nullableField: null);
        final expected = buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: null,
        );

        expect(actual, expected);
      });
    });

    test('toString returns correct string', () {
      expect(
        buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: const Object(),
        ).toString(),
        r"_$TestFormBody(abc, 123, Instance of 'Object')",
      );
    });
  });

  group('Generated Form Errors', () {
    TestFormErrors buildSubject({
      required TestValidationError? stringField,
      required TestValidationError? intField,
      required TestValidationError? nullableField,
    }) {
      return TestFormErrors(
        stringField: stringField,
        intField: intField,
        nullableField: nullableField,
      );
    }

    test('constructor works properly', () {
      expect(
        () => buildSubject(
          stringField: TestValidationError.empty,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        ),
        returnsNormally,
      );
    });

    test('supports value equality', () {
      expect(
        buildSubject(
          stringField: TestValidationError.empty,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        ),
        buildSubject(
          stringField: TestValidationError.empty,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        ),
      );
    });

    test('error fields return entered errors', () {
      final subject = buildSubject(
        stringField: TestValidationError.empty,
        intField: TestValidationError.empty,
        nullableField: TestValidationError.empty,
      );

      expect(subject.stringField, TestValidationError.empty);
      expect(subject.intField, TestValidationError.empty);
      expect(subject.nullableField, TestValidationError.empty);
    });

    group('mergeWhereEmptyWith', () {
      test('replaces empty fields with other', () {
        final subject = buildSubject(
          stringField: null,
          intField: null,
          nullableField: null,
        );
        final other = buildSubject(
          stringField: TestValidationError.empty,
          intField: null,
          nullableField: TestValidationError.empty,
        );

        expect(
          subject.mergeWhereEmptyWith(other: other),
          buildSubject(
            stringField: TestValidationError.empty,
            intField: null,
            nullableField: TestValidationError.empty,
          ),
        );
      });
    });

    group('copyWith', () {
      test('copies object with specified fields replaced', () {
        final subject = buildSubject(
          stringField: null,
          intField: null,
          nullableField: null,
        );
        final actual = subject.copyWith(stringField: TestValidationError.empty);
        final expected = buildSubject(
          stringField: TestValidationError.empty,
          intField: null,
          nullableField: null,
        );

        expect(actual, expected);
      });

      test('supports explicitly setting fields to null', () {
        final subject = buildSubject(
          stringField: TestValidationError.empty,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        );
        final actual = subject.copyWith(stringField: null);
        final expected = buildSubject(
          stringField: null,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        );

        expect(actual, expected);
      });
    });

    test('errors getter returns all errors', () {
      expect(
        buildSubject(
          stringField: TestValidationError.empty,
          intField: null,
          nullableField: TestValidationError.empty,
        ).errors,
        [
          TestValidationError.empty,
          null,
          TestValidationError.empty,
        ],
      );
    });

    test('toString returns correct string', () {
      expect(
        buildSubject(
          stringField: TestValidationError.empty,
          intField: null,
          nullableField: TestValidationError.empty,
        ).toString(),
        'TestFormErrors(TestValidationError.empty, null, TestValidationError.empty)',
      );
    });
  });
}
