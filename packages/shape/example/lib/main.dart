import 'package:shape_example/example_form_body.dart';

void main() {
  print(r'''
This project is not meant to be run like a normal Dart project, but instead
showcases how to generate form bodies using Shape.

Generate the form bodies by running:
  dart run build_runner build --delete-conflicting-outputs
''');

  final form = ExampleFormBody(name: 'John');
  print('Example form: $form');
  print('Example form errors: ${form.validate()}');

  final invalidForm = ExampleFormBody(name: null, age: 25);
  print('Invalid example form: $invalidForm');
  print('Invalid example form errors: ${invalidForm.validate()}');
}
