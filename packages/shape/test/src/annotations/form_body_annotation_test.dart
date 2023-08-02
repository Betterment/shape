import 'package:checks/checks.dart';
import 'package:shape/shape.dart';
import 'package:test/test.dart' hide expect;

void main() {
  group('GenerateFormBody annotation', () {
    GenerateFormBody buildSubject({
      bool? generateFormErrors,
    }) {
      return GenerateFormBody(
        generateFormErrors: generateFormErrors,
      );
    }

    test('can be constructed', () {
      check(buildSubject).returnsNormally().isA<GenerateFormBody>();
    });

    test('has correct props', () {
      final subject = buildSubject();

      check(subject.props).deepEquals([
        subject.generateFormErrors,
      ]);
    });
  });
}
