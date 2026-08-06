import 'package:checks/checks.dart';
import 'package:shape/shape.dart';
import 'package:test/test.dart' hide expect;

void main() {
  group('GenerateFormBody annotation', () {
    GenerateFormBody buildSubject({bool? generateFormErrors}) {
      return GenerateFormBody(generateFormErrors: generateFormErrors);
    }

    test('can be constructed', () {
      check(buildSubject).returnsNormally().isA<GenerateFormBody>();
    });

    test('compares equal when generateFormErrors matches', () {
      final subject = buildSubject();

      check(subject).equals(const GenerateFormBody(generateFormErrors: true));
    });

    test('hashCode matches generateFormErrors', () {
      check(
        buildSubject(generateFormErrors: true).hashCode,
      ).equals(true.hashCode);
      check(
        buildSubject(generateFormErrors: false).hashCode,
      ).equals(false.hashCode);
    });
  });

  group('FieldRequired annotation', () {
    test('can be constructed', () {
      check(() => const FieldRequired()).returnsNormally().isA<FieldRequired>();
    });
  });
}
