// ignore_for_file: prefer_const_constructors
import 'package:checks/checks.dart';
import 'package:shape/shape.dart';
import 'package:test/test.dart' hide expect;

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
      check(TestFormBody.new).returnsNormally();
    });

    test('validate method returns correct type', () {
      check(TestFormBody().validate()).isA<TestFormErrors>();
    });
  });

  group('FormErrors', () {
    const emptyFormErrors = TestFormErrors([null, null, null]);
    const nonEmptyFormErrors = TestFormErrors(['Error', 123, null]);

    test('can be instantiated', () {
      check(() => TestFormErrors(const [])).returnsNormally();
    });

    test('TestFormErrors.errors field returns given errors', () {
      check(nonEmptyFormErrors._errors).equals(nonEmptyFormErrors.errors);
    });

    test('isNotEmpty is true when list is not empty '
        'and contains non-null values', () {
      check(emptyFormErrors.isNotEmpty).isFalse();
      check(nonEmptyFormErrors.isNotEmpty).isTrue();
    });

    test('isEmpty is true when list is empty or only contains null values', () {
      check(emptyFormErrors.isEmpty).isTrue();
      check(nonEmptyFormErrors.isEmpty).isFalse();
    });
  });
}
