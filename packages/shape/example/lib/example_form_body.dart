import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

part 'example_form_body.g.dart';

@GenerateFormBody()
abstract class ExampleFormBody extends FormBody<ExampleFormErrors>
    with _$ExampleFormBodyFields {
  factory ExampleFormBody({
    required String? name,
    int? age,
  }) {
    return _$ExampleFormBody(
      name: GenericFormField(name, isRequired: true),
      age: GenericFormField(age),
    );
  }

  const ExampleFormBody._();
}
