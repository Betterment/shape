import 'package:checks/checks.dart';
import 'package:shape_generator/src/models/generated_class_names.dart';
import 'package:test/test.dart' hide expect;

void main() {
  group('GeneratedClassNames', () {
    test('strips Body suffix for form errors class name', () {
      const names = GeneratedClassNames(formBodyClassName: 'ExampleFormBody');

      check(names.generatedFormErrorsClassName).equals('ExampleFormErrors');
    });

    test('uses full class name when Body suffix is absent', () {
      const names = GeneratedClassNames(formBodyClassName: 'MyForm');

      check(names.generatedFormErrorsClassName).equals('MyFormErrors');
    });

    test('builds generated form body and mixin names', () {
      const names = GeneratedClassNames(formBodyClassName: 'ExampleFormBody');

      check(names.generatedFormBodyClassName).equals('_\$ExampleFormBody');
      check(
        names.generatedFormBodyFieldsMixinName,
      ).equals('_\$ExampleFormBodyFields');
    });
  });
}
