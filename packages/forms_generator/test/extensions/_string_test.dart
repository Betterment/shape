import 'package:forms_generator/src/extensions/extensions.dart';
import 'package:forms_generator/src/models/generator_context.dart';
import 'package:test/test.dart';

void main() {
  group('StringExtensions', () {
    group('appendIfNotPresent', () {
      test('does nothing if suffix is already present', () {
        expect(
          'foobar'.appendIfNotPresent('bar'),
          'foobar',
        );
      });

      test('appends suffix if not present', () {
        expect(
          'foo'.appendIfNotPresent('bar'),
          'foobar',
        );
      });
    });

    group('nullableTypeString', () {
      group('without a null-safe context', () {
        setUp(() {
          GeneratorContext.instance = const GeneratorContext(
            isNullSafetyEnabled: false,
          );
        });

        test('does nothing', () {
          expect(
            'Object'.nullableTypeString,
            'Object',
          );
        });

        test('removes the trailing question mark', () {
          expect(
            'Object?'.nullableTypeString,
            'Object',
          );
        });
      });

      group('with a null-safe context', () {
        setUp(() {
          GeneratorContext.instance = const GeneratorContext(
            isNullSafetyEnabled: true,
          );
        });

        test('appends a trailing question mark', () {
          expect(
            'Object'.nullableTypeString,
            'Object?',
          );
        });

        test('does nothing if trailing question mark is already present', () {
          expect(
            'Object?'.nullableTypeString,
            'Object?',
          );
        });
      });
    });
  });
}
