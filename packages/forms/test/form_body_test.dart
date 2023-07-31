// ignore_for_file: prefer_const_constructors
import 'package:forms/forms.dart';
import 'package:test/test.dart';

class TestFormBody extends FormBody<TestFormErrors> with EquatableMixin {
  const TestFormBody();

  @override
  TestFormErrors validate() => const TestFormErrors([]);

  @override
  List<Object?> get props => [];
}

class TestFormErrors extends FormErrors<TestFormBody> {
  const TestFormErrors(this._errors);
  final List<Object?> _errors;

  @override
  List<Object?> get errors => _errors;
}

void main() {
  group('FormBody', () {
    test('can be instantiated', () {
      expect(
        TestFormBody.new,
        returnsNormally,
      );
    });

    test('validate method returns correct type', () {
      expect(
        TestFormBody().validate(),
        isA<TestFormErrors>(),
      );
    });
  });

  group('FormErrors', () {
    const emptyFormErrors = TestFormErrors([null, null, null]);
    const nonEmptyFormErrors = TestFormErrors(['Error', 123, null]);

    test('can be instantiated', () {
      expect(
        () => TestFormErrors(const []),
        returnsNormally,
      );
    });

    test('TestFormErrors.errors field returns given errors', () {
      expect(
        nonEmptyFormErrors._errors,
        nonEmptyFormErrors.errors,
      );
    });

    test(
        'isNotEmpty is true when list is not empty and contains non-null values',
        () {
      expect(
        emptyFormErrors.isNotEmpty,
        isFalse,
      );
      expect(
        nonEmptyFormErrors.isNotEmpty,
        isTrue,
      );
    });

    test('isEmpty is true when list is empty or only contains null values', () {
      expect(
        emptyFormErrors.isEmpty,
        isTrue,
      );
      expect(
        nonEmptyFormErrors.isEmpty,
        isFalse,
      );
    });
  });
}
