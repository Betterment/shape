import 'package:checks/checks.dart';
import 'package:shape/shape.dart';
import 'package:test/test.dart' hide expect;

class TestFormField<R, T, E> extends FormField<R?, R?, E> {
  TestFormField({
    required R? rawValue,
    E? error,
  })  : _error = error,
        super(rawValue);

  @override
  R? get value => rawValue;

  final E? _error;

  @override
  E? validate() {
    return _error;
  }
}

void main() {
  group('FormField', () {
    group('constructor', () {
      test('binds given value to value field', () {
        final subject = TestFormField<String, String, void>(
          rawValue: 'mock-value',
        );

        check(subject.value).equals('mock-value');
      });
    });

    group('validate', () {
      test('returns instance of error type', () {
        final subject = TestFormField<void, String, String>(
          rawValue: null,
          error: 'mock-error',
        );

        check(subject.validate()).equals('mock-error');
      });
    });
  });
}
