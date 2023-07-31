import 'package:analyzer/dart/element/type.dart';
import 'package:forms_generator/src/extensions/extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

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
          when(
            () => type.getDisplayString(
              withNullability: any(named: 'withNullability'),
            ),
          ).thenReturn(typeDisplayString);
        });

        test('returns type without question mark', () {
          expect(
            type.nonNullableDisplayString,
            typeDisplayString,
          );
        });
      });

      group('on a nullable type', () {
        setUp(() {
          when(
            () => type.getDisplayString(
              withNullability: captureAny(named: 'withNullability'),
            ),
          ).thenAnswer(
            (invocation) {
              final withNullability = invocation
                  .namedArguments[const Symbol('withNullability')] as bool;
              return withNullability
                  ? nullableTypeDisplayString
                  : typeDisplayString;
            },
          );
        });

        test('returns type without question mark', () {
          expect(
            type.nonNullableDisplayString,
            typeDisplayString,
          );
        });
      });
    });

    group('potentiallyNullableDisplayString', () {
      group('without a null-safe context', () {
        setUp(() {
          when(
            () => type.getDisplayString(
              withNullability: any(named: 'withNullability'),
            ),
          ).thenReturn(typeDisplayString);
        });

        test('returns type without question mark', () {
          expect(
            type.potentiallyNullableDisplayString,
            typeDisplayString,
          );
        });
      });

      group('with a null-safe context on a nullable type', () {
        setUp(() {
          when(
            () => type.getDisplayString(
              withNullability: captureAny(named: 'withNullability'),
            ),
          ).thenAnswer(
            (invocation) {
              final withNullability = invocation
                  .namedArguments[const Symbol('withNullability')] as bool;
              return withNullability
                  ? nullableTypeDisplayString
                  : typeDisplayString;
            },
          );
        });

        test('returns type with question mark', () {
          expect(
            type.potentiallyNullableDisplayString,
            nullableTypeDisplayString,
          );
        });
      });
    });
  });
}
