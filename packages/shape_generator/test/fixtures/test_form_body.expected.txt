// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_form_body.dart';

// **************************************************************************
// ShapeGenerator
// **************************************************************************

// ignore_for_file: unused_element, cast_nullable_to_non_nullable, prefer_const_constructors_in_immutables
// Form Body "_$TestFormBody"
@immutable
class _$TestFormBody extends TestFormBody {
  factory _$TestFormBody({
    required NonEmptyStringFormField stringField,
    required ValidIntFormField intField,
    required NullableFormField<Object?> nullableField,
  }) {
    return _$TestFormBody._(stringField, intField, nullableField);
  }
  const _$TestFormBody._(this._stringField, this._intField, this._nullableField)
    : super._();
  @override
  final NonEmptyStringFormField _stringField;
  @override
  String get stringField => _stringField.value;
  @override
  final ValidIntFormField _intField;
  @override
  int? get intField => _intField.value;
  @override
  final NullableFormField<Object?> _nullableField;
  @override
  Object? get nullableField => _nullableField.value;
  @override
  TestFormErrors validate() {
    return TestFormErrors(
      stringField: _stringField.validate(),
      intField: _intField.validate(),
      nullableField: _nullableField.validate(),
    );
  }

  @override
  _$TestFormBodyCopyWith get copyWith => _$TestFormBodyCopyWithImpl(this);
  @override
  bool operator ==(Object other) {
    return other is _$TestFormBody &&
        other._stringField.rawValue == _stringField.rawValue &&
        other._intField.rawValue == _intField.rawValue &&
        other._nullableField.rawValue == _nullableField.rawValue;
  }

  @override
  int get hashCode => Object.hash(
    _stringField.rawValue,
    _intField.rawValue,
    _nullableField.rawValue,
  );
}

// Copy With Interface "_$TestFormBodyCopyWith"
abstract class _$TestFormBodyCopyWith {
  TestFormBody call({
    NonEmptyStringFormField stringField,
    ValidIntFormField intField,
    NullableFormField<Object?> nullableField,
  });
}

// Copy With Implementation "_$TestFormBodyCopyWithImpl"
class _$TestFormBodyCopyWithImpl implements _$TestFormBodyCopyWith {
  const _$TestFormBodyCopyWithImpl(this._instance);
  final _$TestFormBody _instance;
  static const _defaultValue = Object();
  @override
  TestFormBody call({
    Object? stringField = _defaultValue,
    Object? intField = _defaultValue,
    Object? nullableField = _defaultValue,
  }) {
    return _$TestFormBody(
      stringField: stringField == _defaultValue
          ? _instance._stringField
          : stringField! as NonEmptyStringFormField,
      intField: intField == _defaultValue
          ? _instance._intField
          : intField! as ValidIntFormField,
      nullableField: nullableField == _defaultValue
          ? _instance._nullableField
          : nullableField! as NullableFormField<Object?>,
    );
  }
}

// Form Fields Mixin "_$TestFormBodyFields"
mixin _$TestFormBodyFields {
  /// The internal stringField field form field.
  ///
  /// This property should not be exposed and is only to be used when implementing a
  /// custom `validate` method.
  NonEmptyStringFormField get _stringField;

  /// The parsed value of the stringField field.
  String get stringField;

  /// The internal intField field form field.
  ///
  /// This property should not be exposed and is only to be used when implementing a
  /// custom `validate` method.
  ValidIntFormField get _intField;

  /// The parsed value of the intField field.
  int? get intField;

  /// The internal nullableField field form field.
  ///
  /// This property should not be exposed and is only to be used when implementing a
  /// custom `validate` method.
  NullableFormField<Object?> get _nullableField;

  /// The parsed value of the nullableField field.
  Object? get nullableField;
  TestFormErrors validate();

  /// Copies this TestFormBody and replaces the provided fields.
  _$TestFormBodyCopyWith get copyWith;
}

// Form Errors "TestFormErrors"
@immutable
/// The form errors for the form body "TestFormBody".
class TestFormErrors extends FormErrors {
  /// The form errors for the form body "TestFormBody".
  const TestFormErrors({this.stringField, this.intField, this.nullableField});

  /// The error for the stringField field.
  final TestValidationError? stringField;

  /// The error for the intField field.
  final TestValidationError? intField;

  /// The error for the nullableField field.
  final TestValidationError? nullableField;

  /// Merges this TestFormErrors with the [other]
  /// by replacing any empty fields in this instance with the corresponding field in
  /// [other] while preserving the non-empty fields in this instance.
  TestFormErrors mergeWhereEmptyWith({required TestFormErrors other}) {
    return TestFormErrors(
      stringField: stringField ?? other.stringField,
      intField: intField ?? other.intField,
      nullableField: nullableField ?? other.nullableField,
    );
  }

  /// Copies this TestFormErrors and replaces the provided fields.
  _TestFormErrorsCopyWith get copyWith => _TestFormErrorsCopyWithImpl(this);
  @override
  List<Object?> get errors => [stringField, intField, nullableField];
  @override
  bool operator ==(Object other) {
    return other is TestFormErrors &&
        other.stringField == stringField &&
        other.intField == intField &&
        other.nullableField == nullableField;
  }

  @override
  int get hashCode => Object.hash(stringField, intField, nullableField);
}

// Copy With Interface "_TestFormErrorsCopyWith"
abstract class _TestFormErrorsCopyWith {
  TestFormErrors call({
    TestValidationError? stringField,
    TestValidationError? intField,
    TestValidationError? nullableField,
  });
}

// Copy With Implementation "_TestFormErrorsCopyWithImpl"
class _TestFormErrorsCopyWithImpl implements _TestFormErrorsCopyWith {
  const _TestFormErrorsCopyWithImpl(this._instance);
  final TestFormErrors _instance;
  static const _defaultValue = Object();
  @override
  TestFormErrors call({
    Object? stringField = _defaultValue,
    Object? intField = _defaultValue,
    Object? nullableField = _defaultValue,
  }) {
    return TestFormErrors(
      stringField: stringField == _defaultValue
          ? _instance.stringField
          : stringField as TestValidationError?,
      intField: intField == _defaultValue
          ? _instance.intField
          : intField as TestValidationError?,
      nullableField: nullableField == _defaultValue
          ? _instance.nullableField
          : nullableField as TestValidationError?,
    );
  }
}
