import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:checks/checks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/models/client_class_metadata.dart';
import 'package:shape_generator/src/models/form_body_field_metadata.dart';
import 'package:test/test.dart' hide expect;

class _MockInterfaceType extends Mock implements InterfaceType {}

void main() {
  group('FormBodyFieldMetadata', () {
    late InterfaceType formClassType;
    late ClientClassMetadata formClassMetadata;

    setUp(() {
      formClassType = _MockInterfaceType();
      when(() => formClassType.getDisplayString()).thenReturn('NameFormField');
      when(
        () => formClassType.potentiallyNullableDisplayString,
      ).thenReturn('NameFormField');
      when(
        () => formClassType.nullabilitySuffix,
      ).thenReturn(NullabilitySuffix.none);

      formClassMetadata = ClientClassMetadata(
        baseType: formClassType,
        supertype: null,
        instanceType: formClassType,
        isAbstract: false,
        isEnum: false,
        isMixin: false,
        constructors: const [],
        fields: const {},
        methods: const [],
        typeParameters: const [],
      );
    });

    FormBodyFieldMetadata buildSubject({
      String fieldName = 'name',
      String wrapperExpression = 'name',
      bool isCustomWrapper = false,
    }) {
      return FormBodyFieldMetadata(
        fieldName: fieldName,
        formClassMetadata: formClassMetadata,
        wrapperExpression: wrapperExpression,
        isCustomWrapper: isCustomWrapper,
      );
    }

    test('extendsFormField is false when supertype is null', () {
      check(buildSubject().extendsFormField).isFalse();
    });

    test('rawValueType, valueType, and errorType fall back to form type', () {
      final subject = buildSubject();

      check(subject.rawValueType).equals(formClassType);
      check(subject.valueType).equals(formClassType);
      check(subject.errorType).equals(formClassType);
    });

    test('toString includes key fields', () {
      check(buildSubject(isCustomWrapper: true).toString()).equals(
        'FormBodyFieldMetadata('
        'fieldName: name, '
        'wrapperExpression: name, '
        'isCustomWrapper: true, '
        'formClassMetadata: $formClassMetadata, '
        'genericTypeArguments: {}'
        ')',
      );
    });

    test('copyWith replaces provided fields', () {
      final subject = buildSubject();
      final copy = subject.copyWith(
        fieldName: 'age',
        wrapperExpression: 'GenericFormField(age)',
        isCustomWrapper: true,
      );

      check(copy.fieldName).equals('age');
      check(copy.wrapperExpression).equals('GenericFormField(age)');
      check(copy.isCustomWrapper).isTrue();
      check(copy.formClassMetadata).equals(formClassMetadata);
    });
  });
}
