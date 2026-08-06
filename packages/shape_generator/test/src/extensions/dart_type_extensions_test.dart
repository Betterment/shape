import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:checks/checks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:test/test.dart' hide expect;

class MockType extends Mock implements DartType {}

void main() {
  group('DartTypeExtensions', () {
    const typeDisplayString = 'MockType';
    const nullableTypeDisplayString = 'MockType?';

    late DartType type;

    setUp(() {
      type = MockType();
    });

    group('nonNullableDisplayString', () {
      group('on a non-nullable type', () {
        setUp(() {
          when(type.getDisplayString).thenReturn(typeDisplayString);
          when(() => type.nullabilitySuffix).thenReturn(NullabilitySuffix.none);
        });

        test('returns type without question mark', () {
          check(type.nonNullableDisplayString).equals(typeDisplayString);
        });
      });

      group('on a nullable type', () {
        setUp(() {
          when(type.getDisplayString).thenReturn(nullableTypeDisplayString);
          when(
            () => type.nullabilitySuffix,
          ).thenReturn(NullabilitySuffix.question);
        });

        test('returns type without question mark', () {
          check(type.nonNullableDisplayString).equals(typeDisplayString);
        });
      });
    });

    group('potentiallyNullableDisplayString', () {
      setUp(() {
        when(type.getDisplayString).thenReturn(nullableTypeDisplayString);
      });

      test('returns type with question mark', () {
        check(
          type.potentiallyNullableDisplayString,
        ).equals(nullableTypeDisplayString);
      });
    });

    test('leaves star suffix display strings unchanged', () {
      when(type.getDisplayString).thenReturn('MockType*');
      when(() => type.nullabilitySuffix).thenReturn(NullabilitySuffix.star);

      check(type.potentiallyNullableDisplayString).equals('MockType*');
      check(type.nonNullableDisplayString).equals('MockType*');
    });
  });
}
