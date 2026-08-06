import 'package:checks/checks.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';
import 'package:test/test.dart' hide expect;

import 'package:shape_example/example_form_body.dart';

void main() {
  group('ExampleFormBody', () {
    test('can be constructed and exposes parsed values', () {
      final formBody = ExampleFormBody(name: 'Ada', age: 42);

      check(formBody.name).equals('Ada');
      check(formBody.age).equals(42);
    });

    test('validate returns generated errors', () {
      final formBody = ExampleFormBody(name: null, age: null);
      final errors = formBody.validate();

      check(errors.name).equals(GenericValidationError.missing);
      check(errors.isNotEmpty).isTrue();
    });

    test('copyWith replaces provided fields', () {
      final formBody = ExampleFormBody(name: 'Ada', age: 42);
      final updated = formBody.copyWith(name: 'Grace');

      check(updated.name).equals('Grace');
      check(updated.age).equals(42);
    });
  });
}
