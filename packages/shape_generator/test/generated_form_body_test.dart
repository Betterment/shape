import 'package:checks/checks.dart';
import 'package:test/test.dart' hide expect;
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
      check(
        () => buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: null,
        ),
      ).returnsNormally().isA<TestFormBody>();
    });

    test('supports value equality', () {
      check(
        buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: const Object(),
        ),
      ).equals(
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

      check(subject.stringField).equals('abc');
      check(subject.intField).equals(123);
      check(subject.nullableField).equals(const Object());
    });

    group('validate', () {
      test('returns a generated form errors instance', () {
        check(
          buildSubject(
            stringField: 'abc',
            intField: '123',
            nullableField: const Object(),
          ).validate,
        ).returnsNormally().isA<TestFormErrors>();
      });

      test('validates all fields', () {
        check(
          buildSubject(
            stringField: 'abc',
            intField: '123',
            nullableField: const Object(),
          ).validate,
        ).returnsNormally().equals(const TestFormErrors());

        check(
          buildSubject(
            stringField: '',
            intField: 'abc',
            nullableField: null,
          ).validate,
        ).returnsNormally().equals(
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
        final checked = buildSubject(
          stringField: 'def',
          intField: '123',
          nullableField: const Object(),
        );

        check(actual).equals(checked);
      });

      test('supports explicitly setting nullable fields to null', () {
        final subject = buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: 'xyz',
        );
        final actual = subject.copyWith(nullableField: null);
        final checked = buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: null,
        );

        check(actual).equals(checked);
      });
    });

    test('toString returns correct string', () {
      check(
        buildSubject(
          stringField: 'abc',
          intField: '123',
          nullableField: const Object(),
        ).toString,
      ).returnsNormally().equals(
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
      check(
        () => buildSubject(
          stringField: TestValidationError.empty,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        ),
      ).returnsNormally();
    });

    test('supports value equality', () {
      check(
        buildSubject(
          stringField: TestValidationError.empty,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        ),
      ).equals(
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

      check(subject.stringField).equals(TestValidationError.empty);
      check(subject.intField).equals(TestValidationError.empty);
      check(subject.nullableField).equals(TestValidationError.empty);
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

        check(subject.mergeWhereEmptyWith(other: other)).equals(
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
        final checked = buildSubject(
          stringField: TestValidationError.empty,
          intField: null,
          nullableField: null,
        );

        check(actual).equals(checked);
      });

      test('supports explicitly setting fields to null', () {
        final subject = buildSubject(
          stringField: TestValidationError.empty,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        );
        final actual = subject.copyWith(stringField: null);
        final checked = buildSubject(
          stringField: null,
          intField: TestValidationError.empty,
          nullableField: TestValidationError.empty,
        );

        check(actual).equals(checked);
      });
    });

    test('errors getter returns all errors', () {
      check(
        buildSubject(
          stringField: TestValidationError.empty,
          intField: null,
          nullableField: TestValidationError.empty,
        ),
      ).has((e) => e.errors, 'errors').deepEquals([
        TestValidationError.empty,
        null,
        TestValidationError.empty,
      ]);
    });

    test('toString returns correct string', () {
      check(
        buildSubject(
          stringField: TestValidationError.empty,
          intField: null,
          nullableField: TestValidationError.empty,
        ).toString,
      ).returnsNormally().equals(
        '''TestFormErrors(TestValidationError.empty, null, TestValidationError.empty)''',
      );
    });
  });
}
