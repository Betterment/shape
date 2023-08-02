import 'package:shape_generator/src/extensions/extensions.dart';
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
}
