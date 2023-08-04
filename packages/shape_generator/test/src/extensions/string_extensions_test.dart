import 'package:checks/checks.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:test/test.dart' hide expect;

void main() {
  group('StringExtensions', () {
    group('appendIfNotPresent', () {
      test('does nothing if suffix is already present', () {
        check('foobar'.appendIfNotPresent('bar')).equals('foobar');
      });

      test('appends suffix if not present', () {
        check('foo'.appendIfNotPresent('bar')).equals('foobar');
      });
    });

    group('nullableTypeString', () {
      test('appends a trailing question mark', () {
        check('Object'.nullableTypeString).equals('Object?');
      });

      test('does nothing if trailing question mark is already present', () {
        check('Object?'.nullableTypeString).equals('Object?');
      });
    });
  });
}
