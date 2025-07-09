// ignore_for_file: avoid_returning_null
import 'package:shape/shape.dart';

part 'test_form_body.g.dart';

@GenerateFormBody()
abstract class TestFormBody extends FormBody<TestFormErrors>
    with _$TestFormBodyFields {
  factory TestFormBody({
    required String stringField,
    required String intField,
    required Object? nullableField,
  }) {
    return _$TestFormBody(
      stringField: NonEmptyStringFormField(rawValue: stringField),
      intField: ValidIntFormField(rawValue: intField),
      nullableField: NullableFormField<Object?>(rawValue: nullableField),
    );
  }

  const TestFormBody._();
}

enum TestValidationError { empty }

class NonEmptyStringFormField
    extends FormField<String, String, TestValidationError> {
  NonEmptyStringFormField({required String rawValue}) : super(rawValue);

  @override
  String get value => rawValue;

  @override
  TestValidationError? validate() {
    if (value.isEmpty) {
      return TestValidationError.empty;
    } else {
      return null;
    }
  }
}

class ValidIntFormField extends FormField<String, int?, TestValidationError> {
  ValidIntFormField({required String rawValue}) : super(rawValue);

  @override
  int? get value => int.tryParse(rawValue);

  @override
  TestValidationError? validate() {
    if (value == null) {
      return TestValidationError.empty;
    } else {
      return null;
    }
  }
}

class NullableFormField<T> extends FormField<T?, T?, TestValidationError> {
  NullableFormField({required T rawValue}) : super(rawValue);

  @override
  T? get value => rawValue;

  @override
  TestValidationError? validate() {
    if (rawValue == null) {
      return TestValidationError.empty;
    } else {
      return null;
    }
  }
}
