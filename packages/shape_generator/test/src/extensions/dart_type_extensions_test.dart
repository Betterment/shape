import 'package:analyzer/dart/element/type.dart';
import 'package:checks/checks.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart' hide expect;

class MockType extends Mock implements DartType {}

void main() {
  group('DartTypeExtensions', () {
    final typeDisplayString = '$MockType';
    final nullableTypeDisplayString = '$MockType?';

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
          check(type.nonNullableDisplayString).equals(typeDisplayString);
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
          check(type.nonNullableDisplayString).equals(typeDisplayString);
        });
      });
    });

    group('potentiallyNullableDisplayString', () {
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
        check(type.potentiallyNullableDisplayString)
            .equals(nullableTypeDisplayString);
      });
    });
  });
}
