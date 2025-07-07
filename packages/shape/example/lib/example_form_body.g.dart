// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_form_body.dart';

// **************************************************************************
// ShapeGenerator
// **************************************************************************

// Form Body "_$ExampleFormBody"
@immutable
class _$ExampleFormBody extends ExampleFormBody
    with _$ExampleFormBodyFields, EquatableMixin {
  factory _$ExampleFormBody({
    required GenericFormField<String?> name,
    required GenericFormField<int?> age,
  }) {
    return _$ExampleFormBody._(name, age);
  }
  const _$ExampleFormBody._(this._name, this._age) : super._();
  @override
  final GenericFormField<String?> _name;
  @override
  String? get name => _name.value;
  @override
  final GenericFormField<int?> _age;
  @override
  int? get age => _age.value;
  @override
  ExampleFormErrors validate() {
    return ExampleFormErrors(name: _name.validate(), age: _age.validate());
  }

  @override
  _$ExampleFormBodyCopyWith get copyWith => _$ExampleFormBodyCopyWithImpl(this);
  @override
  List<Object?> get props => [_name.rawValue, _age.rawValue];
  @override
  bool get stringify => true;
}

// Copy With Interface "_$ExampleFormBodyCopyWith"
abstract class _$ExampleFormBodyCopyWith {
  ExampleFormBody call({String? name, int? age});
}

// Copy With Implementation "_$ExampleFormBodyCopyWithImpl"
class _$ExampleFormBodyCopyWithImpl implements _$ExampleFormBodyCopyWith {
  const _$ExampleFormBodyCopyWithImpl(this._instance);
  final _$ExampleFormBody _instance;
  static const _defaultValue = Object();
  @override
  ExampleFormBody call({
    Object? name = _defaultValue,
    Object? age = _defaultValue,
  }) {
    return ExampleFormBody(
      name: name == _defaultValue ? _instance._name.rawValue : name as String?,
      age: age == _defaultValue ? _instance._age.rawValue : age as int?,
    );
  }
}

// Form Fields Mixin "_$ExampleFormBodyFields"
mixin _$ExampleFormBodyFields {
  /// The internal name field form field.
  ///
  /// This property should not be exposed and is only to be used when implementing a
  /// custom `validate` method.
  GenericFormField<String?> get _name;

  /// The parsed value of the name field.
  String? get name;

  /// The internal age field form field.
  ///
  /// This property should not be exposed and is only to be used when implementing a
  /// custom `validate` method.
  GenericFormField<int?> get _age;

  /// The parsed value of the age field.
  int? get age;
  ExampleFormErrors validate();

  /// Copies this ExampleFormBody and replaces the provided fields.
  _$ExampleFormBodyCopyWith get copyWith;
}

// Form Errors "ExampleFormErrors"
@immutable
/// The form errors for the form body "ExampleFormBody".
class ExampleFormErrors extends FormErrors<_$ExampleFormBody>
    with EquatableMixin {
  /// The form errors for the form body "ExampleFormBody".
  const ExampleFormErrors({this.name, this.age});

  /// The error for the name field.
  final GenericValidationError? name;

  /// The error for the age field.
  final GenericValidationError? age;

  /// Merges this ExampleFormErrors with the [other]
  /// by replacing any empty fields in this instance with the corresponding field in
  /// [other] while preserving the non-empty fields in this instance.
  ExampleFormErrors mergeWhereEmptyWith({required ExampleFormErrors other}) {
    return ExampleFormErrors(name: name ?? other.name, age: age ?? other.age);
  }

  /// Copies this ExampleFormErrors and replaces the provided fields.
  _ExampleFormErrorsCopyWith get copyWith =>
      _ExampleFormErrorsCopyWithImpl(this);
  @override
  List<Object?> get errors => [name, age];
  @override
  List<Object?> get props => errors;
  @override
  bool get stringify => true;
}

// Copy With Interface "_ExampleFormErrorsCopyWith"
abstract class _ExampleFormErrorsCopyWith {
  ExampleFormErrors call({
    GenericValidationError? name,
    GenericValidationError? age,
  });
}

// Copy With Implementation "_ExampleFormErrorsCopyWithImpl"
class _ExampleFormErrorsCopyWithImpl implements _ExampleFormErrorsCopyWith {
  const _ExampleFormErrorsCopyWithImpl(this._instance);
  final ExampleFormErrors _instance;
  static const _defaultValue = Object();
  @override
  ExampleFormErrors call({
    Object? name = _defaultValue,
    Object? age = _defaultValue,
  }) {
    return ExampleFormErrors(
      name:
          name == _defaultValue
              ? _instance.name
              : name as GenericValidationError?,
      age:
          age == _defaultValue ? _instance.age : age as GenericValidationError?,
    );
  }
}
